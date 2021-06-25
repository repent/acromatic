# encoding: utf-8
# == Schema Information
#
# Table name: documents
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  file            :string
#  allow_mixedcase :boolean          default(FALSE)
#  allow_plurals   :boolean          default(FALSE)
#  allow_hyphens   :boolean          default(FALSE)
#  allow_numbers   :boolean          default(FALSE)
#  allow_short     :boolean
#  dictionary_id   :integer
#  exclude_roman   :boolean
#  guess_meanings  :boolean
#

# to refresh run annotate

# A note on plurals
# 
# CamelCase never counts as an acronym, so ToRs can *only* be a plural.
# It won't be caught otherwise.
# 
# Some people pluralise legitimately singular acronyms (e.g. NGO, NGOs
# both used in same document).  Here you would normally only list NGO in
# the list, *even if it doesn't appear as a singular in the document*.
# This is not critical though.
# 
# Some people use plurals that they wouldn't use in singular, e.g. TORs
# (meaning terms of reference, rather than multiple sets of terms of
# reference).  Here they should be listed as plural in the definitions.
# 
# So, Acromatic's behaviour should be:
# 
# If only singular exists, list the singular in the definitions.
# 
# If only a plural exists, list a plural in the definitions.
# 
# If both exist, treat them separately, in parallel.
# 
# Ignore the following rabbit hole!...
# 
# If both singluar and plurals exist in the same document   * Search for
# meaning against singular first, then plural (even if the plural def
# comes first -- though this is for convenience, if both are defined I
# can't see how it matters which def is used)   * List only one in the
# definitions, ideally singular     * What if you only have the
# definition for the plural?
# 
# Alternatives:   * treat them as separate (list TOR with def, and TORs
# with def if they are both defined, let the user sort this out)   *
# make lots of assumptions   * permit user to apply a set of
# assumptions, or go with (1) -- but this might have to happen at parse
# time
# 
# Argh.

class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  has_many :acronyms
  belongs_to :dictionary
  validates :file, presence: true

  CONTEXT = 60

  Context = Struct.new(:before, :after)

  ################################################################
  # The Pattern
  #pattern = /\b[A-Z]{2,}\b/ # restrictive
  #pattern = /\b([A-Z,0-9][A-z,0-9,-]+[A-Z,0-9](s)?)\b/ # liberal, 3-letter minimum, can starwith number
  # don't need the \b, knowing that the char inside is \w
  # /[\W]([A-Z][A-z,0-9,&-+]*[A-Z,0-9+-](s)?)[\W]/ fails -- the comma counts

  # Note that A-z includes square brackets

  # Retired on 15.6.21:
  #   Because: it matches R[E
  #   PATTERN = /[\W]([A-Z][A-z0-9&-+]*[A-Z0-9+-](s)?)[\W]/ # liberal, 2-letter minimum, 

  # Retired on 15.6.21:
  #   Because: it matches Australia-
  #   PATTERN = /[\W]([A-Z][a-zA-Z0-9&-+]*[A-Z0-9+-](s)?)[\W]/ # liberal, 2-letter minimum, 

  # Failing on 24.6.21:
  #   Because: IS-LM shows up as "IS" and "LM" separately
  #   PATTERN = /[\W]([A-Z][a-zA-Z0-9&-+]*[A-Z][0-9+-]?(s)?)[\W]/ # liberal, 2-letter minimum, must start with letter and have another capital before the end junk

  # 24.6.21: Hyphen has been cut out completely, inside and at end
  # so IS-LM picks up IS and LM separately
  PATTERN = /[\W]([A-Z][a-zA-Z0-9&]*[A-Z][0-9+]?(s)?)[\W]/ # liberal, 2-letter minimum, must start with letter and have another capital before the end junk

  #pattern = /\b([A-Z][A-z,0-9,&-]*[A-Z,0-9](s)?)\b/ # liberal, 2-letter minimum, must starwith letter
  ################################################################

  # # There are better ways of doing this with callbacks but the kludgy way we're creating a text
  # # version of the file makes it not obvious where to do this
  # def remove_original # deletes original (maybe large) .docx file, called just before trawl
  #   # This breaks refreshes -- seemingly can't reparse document
  #   File.delete self.file.file.file
  # end

  def self.log(doc) # record basic details about this document, since the record will expire
    @@document_log ||= Logger.new Rails.root.join('log', 'document_uploads.log')
    @@document_log.info "#{File.basename doc.file_url}" # [dict: #{doc.dictionary_id.to_s}]"
  end

  def log_pathcronym(ac)
    @@pathcronym_log ||= Logger.new Rails.root.join('log', 'acronyms_causing_errors.log')
    @@pathcronym_log.error ac
  end

  def trawl
    # By this point the files have been moved to their final location in uploads/document/file/xxx
    
    # Grab the text version of this document
    text = File.readlines(self.file.versions[:text].file.file).join
    
    # Do stuff each time an acronym is found in the code
    text.scan(PATTERN) do |ac|
      # pattern contains groups (with parentheses), so ac will be an array (0: whole match, 1: plural 's')
      # This will be just the s if it exists
      # This means that the acronym list will contain
      #   TOR
      #   s
      # if TORs is matched

      # If a plural has been found, record the singular in initialism, but remember (temporarily) that this was a plural so that we can record the definition differently
      plural = (ac[1] == 's')
      singular = !plural
      # initialism_as_found includes a plural so that when displayed alongside the saved context the text still makes sense
      initialism_as_found = ac[0]

      ac = ac[0]
      ac = ac[0...-1] if ac[-1] == 's'

      existing_record = self.acronyms.where(initialism: ac).first # nil if none

      # To do (here and above):
      #   Allow rescanning with different parsing options:
      #    ending in s (TORs)
      #    internal lower case (AusAID)
      #    internal hyphen (BIG-T)
      #    numbers (BICF2)

      # First check: does this already exist?  If so, skip.
      #   If it exists, and has meaning, skip
      #   If it exists but has no meaning, tough -- this will have been searched for the first
      #   time it showed up
      #   So, if it exists, skip

      # SKIP if already recorded with meaning
      # TODO: something different if the plural has previously been found, but we now find a singular definition
      # There should now only ever be one instance of this ac in self.acronyms
      # SKIP if
      #   * ac already exists, AND
      #   * there is a singular definition OR this is a plural

      # Continue if this is a new acronym, or the existing entry doesn't have the kind of
      # definition that we have: plural if there is no definition or singular if there is
      # no definition or only a plural one (singular definition assumed to be preferred)
      next if
        # the acronym already exists, AND
        existing_record &&
        (
          # This is plural and there is already ANY definition recorded, OR
          ( plural && existing_record.meaning ) ||
          # This is singular and there is already a SINGULAR definition
          ( singular && !existing_record.defined_in_plural && existing_record.meaning )
        )

      # FROM NOW ON: this acronym doesn't exist or lacks the appropriate meaning.
      # Safe to overwrite the meaning as long as you're not overwriting it with nil (or you could overwrite a plural meaning with a null singular one)

      # TODO: Plurals are an arse
      # May want to:
      #  Highlight if there are acronyms that are otherwise identical but different case
      #    (suggests mistake)
      #  Highlight if acronyms appear in singular and plural
      #  Only list singular acronyms (i.e. if TORs appear in text, list TOR in list)

      ############################################################################################
      # Create chunks of CONTEXT for various purposes -- NOW REFACTORED
      ############################################################################################
      # Use the first bracketed occurance, if it exists; otherwise, the first occurance
      # [Note that this is the same whether this is the first or tenth time this acronym has
      # been fount (EXCEPT FOR PLURALS), so no need to repeat this]
      #location_of_bracketed = (text =~ /\(#{ac}\)/)
      ## Does the text contain the acronym in brackets anywhere?
      #bracketed = !!location_of_bracketed
      #index = if bracketed
      #  location_of_bracketed
      #else
      #  text =~ /\b#{ac}\b/
      #end
      #
      #raise "#{ac} not found" unless index
      ## TODO:
      ## Now there is a glitch when the ac length is incorrectly measured because it is(n't) bracketed
      ## e.g.: Adopt, Adapt, Expand, Respond AAERR) framework. This provides a way of
      ##                                         ==
      #start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
      #finish = (index + CONTEXT) > text.length ? text.length : index + CONTEXT
      #context_before = text[start...index] # used for display
      #context_after  = text[(index+ac.length)...finish] # display
      context = get_context(initialism_as_found, text)
      #############################################################################################

      ############################################################################################
      # MEANING
      ############################################################################################
      # If the acronym appears in brackets, then try to figure out what it might mean
      # Stuff that gets in the way:
      #   incidental words, e.g. Business Environment for Economic Development
      #   punctuation, e.g. Adopt, Adapt, Expand, Respond; ministries, departments and agencies
      #   apostrophes, e.g. women's economic empowerment
      #   utter stupidity, e.g. making markets work for the poor
      ############################################################################################
      # Perhaps this should be done on display rather on "trawl" --
      # then the dictionary can be changed after the document has been uploaded
      # Perhaps better for "meaning" not to be a db field of an acronym but a pseudo
      # built on demand from the current dictionary
      #meaning = dictionary ? dictionary.lookup(ac) : nil
      meaning = if bracketed?(initialism_as_found, text) and guess_meanings
        get_meaning(initialism_as_found, context.before.chomp('(').rstrip)
      else
        nil
      end

      ############################################################################################
      # CREATE OR CHANGE ACRONYM
      ############################################################################################
      # If the meaning has been learnt from the text, it is put into the database
      # If not, when the list is displayed, we'll try and match it with the chosen dictionary
      #stored_ac = self.acronyms.where(initialism: ac) # will be [] if not defined
      if existing_record
        # TODO: if context stored is plural and we've found a singular, then replace
        #stored_ac = stored_ac.first
        # Get out of here unless we have somethign to add, which could be
        #  * a definition if 
        #     - defined_in_plural_only and singular, OR
        #     - not defined
        #  * a singular listing if plural_only
        #next unless meaning
        # The appropriate meaning should be nil
        #raise "ASSERT: definition should be nil" if (plural && stored_ac.plural_meaning) || (!plural && stored_ac.meaning)
        updates = {}
        if singular
          updates[:plural_only] = false
        end
        if meaning.present? &&
          ( 
            !existing_record.meaning || 
            ( singular && existing_record.defined_in_plural )
          )
          updates[:meaning] = meaning
        end
        if singular && meaning.present?
          updates[:defined_in_plural] = false
        end

        existing_record.update( updates )
      else
        self.acronyms.push Acronym.create(
          initialism: ac, context_before: context.before, context_after: context.after, bracketed: bracketed?(initialism_as_found, text),
            bracketed_on_first_use: bracketed_on_first_use?(initialism_as_found, text),
            meaning: meaning, plural_only: plural, defined_in_plural:
              ( plural && meaning.present? )
          )
      end
      ############################################################################################
    end

    # acronyms.uniq!
    # acronyms.sort!

    # Find out which acronyms first appear in brackets
    # acronyms.each do |ac|
    #   if options.mark_undefined
    #     star = text.match(/\(#{ac}\)/) ? '' : '*'
    #   else
    #     star = ''
    #   end
    #   puts "#{ac}#{star}"
    # end
  end
  
  # acronyms returns everything, this filters with document settings
  def allowed_acronyms
    acronyms.select {|ac| ac.allowed? }
  end

  def acronym_count # .acronyms.length gives all acronyms, including those that have been excluded
    acronyms.collect{ |a| a.allowed? }.count(true)
  end

  private

  def escape(ac)
    # The following characters must be escaped when put into a regexp:
    # ^ $ ? * + - .
    # At present, I think only + and - should show up in an acronym
    ac.gsub('-', '\-').gsub('+', '\+')
  end

  def location_of_bracketed(ac, text) # index of first bracketed instance
    # The following line has raised
    #   RegexpError (premature end of char-class: /\(R[E\)/):
    #   i.e. there is a danger of ac containing an opening square bracket or
    #   other dangerous regexp character
    # begin
    loc = ( text =~ /\(#{escape(ac)}\)/ )
    # rescue RegexpError => e
    #   # TODO: log the pathcronym
    #   log_pathcronym(ac)
    #   return nil
    # end
    return loc+1 if loc # The regexg will show the location of the parethesis
    nil
  end

  def location_of_first_use(ac, text)
    # Rescuing this error doesn't currently help, just obscurs where the error is
    # begin
    # \W: any non-word character
    loc = ( text =~ /\W#{escape(ac)}\W/ )
    return loc+1
    # rescue RegexpError => e
    #   log_pathcronym(ac)
    #   nil
    # end
  end

  def get_index(ac, text)
    if bracketed?(ac, text)
      location_of_bracketed(ac, text)
    else
      location_of_first_use(ac, text)
    end
  end

  def bracketed_on_first_use?(ac, text) # Is the acronym in brackets the first time it appears?
    text =~ /.#{escape(ac)}./ # first match
    ($1 == "(#{ac})")
  end

  def bracketed?(ac, text) # Does the text contain the acronym in brackets anywhere?
    # Also check singular?
    !!location_of_bracketed(ac, text)
  end

  def get_context(ac, text)
    index = get_index(ac, text) # returns char 2 before acronym if bracketed
    
    raise "Acronym #{ac} not re-found in the text document" unless index

    start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
    finish = (index + ac.length + CONTEXT) > text.length ? text.length : index + ac.length + CONTEXT

    Context.new( text[start...index],
      text[(index+ac.length)...finish]
    )
  end

  def get_singular(ac) # Get the singular version
    if ac =~ /(.*)s$/ then $1 else ac end
  end

  public # for testing

  # get_meaning singularises ac before digging
  def get_meaning(ac, previous_text)
    # If ac is plural, then kill the final s before searching for the longhand
    # because MDAs doesn't expand as M*** D** A***** S**.
    incidentals = %W( for in of and the a an )
    @guesslog ||= Logger.new Rails.root.join 'log', 'guessing_meaning_of_acronyms.log'

    # . does not match newlines, (and * is greedy) so this grabs the foregoing paragraph
    #text =~ /(.*)\(#{ac}\)/ # first bracketed case
    #previous_text = $1.rstrip # used to decode acronyms

    # This check done before get_meaning is called
    #return nil unless bracketed?(ac, text)

    meaning = nil
    singular = get_singular(ac)
    #total_definition_length = 100
    #maximum_word_length = 12
    # en-dash is not actually useful -- it seems that the docx2txt converts en-dashes to ' - '
    divider = '[\s\-]+' # Old skool - works, but is limited
    #divider = '[\s\-]+' # trying to catch garbled "public - private partnership"
    word = '\w+' #"\w{1,#{maximum_word_length}"
    case_sensitivity = Regexp::IGNORECASE # right more often than not?
    previous_text = previous_text.rstrip
    previous_text_without_incidentals = previous_text.dup
    incidentals.each do |i|
      previous_text_without_incidentals.gsub!(/\s#{i}\b/, '')
    end
    puts previous_text
    puts previous_text_without_incidentals
    definition_regexp = ''
    #byebug
    #singular_length = singular_length
    singular.each_char.collect{|l| l}.each_with_index do |letter, i|
      # Word
      definition_regexp += letter
      definition_regexp += word
      # Separator
      unless singular.length == (i + 1) # i is zero-indexed
        definition_regexp += divider
      end
    end
    # The definition *must* be immediately before the brackets, (ignoring spaces) --
    # don't want to match a pair of random words earlier in the paragraph
    definition_regexp += '$'
    definition_regexp = Regexp.new definition_regexp, case_sensitivity
    if previous_text =~ definition_regexp
      meaning = $&
      @guesslog.info { "Matched '#{singular}' with '#{meaning}'" }
    elsif previous_text_without_incidentals =~ definition_regexp
      meaning = $&
      @guesslog.info { "Matched '#{singular}' with '#{meaning}' by removing incidental words" }
    else
      text_to_log = 80
      shortened_text = previous_text.length > text_to_log ? previous_text[-text_to_log..-1] : previous_text
      @guesslog.info { "Failed to match '#{singular}' in '#{shortened_text}'"}
    end
    meaning
  end
end
