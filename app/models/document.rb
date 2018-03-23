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

  def trawl
    # By this point the files have been moved to their final location in uploads/document/file/xxx
    
    # Grab the text version of this document
    text = File.readlines(self.file.versions[:text].file.file).join
    
    #pattern = /\b[A-Z]{2,}\b/ # restrictive
    #pattern = /\b([A-Z,0-9][A-z,0-9,-]+[A-Z,0-9](s)?)\b/ # liberal, 3-letter minimum, can start with number
    pattern = /\b([A-Z][A-z,0-9,-]*[A-Z,0-9](s)?)\b/ # liberal, 2-letter minimum, must start with letter

    # Do stuff each time an acronym is found in the code
    text.scan(pattern) do |ac|
      # pattern contains groups (with parentheses), so ac will be an array (0: whole match, 1: plural 's')
      # This will include the s if it exists
      # This means that the acronym list will contain
      #   TOR
      #   TORs
      # if both appear
      # and this is less bad than any other option
      ac = ac[0]

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
      next unless self.acronyms.where(initialism: ac).empty? # skip if already recorded

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
      context = get_context(ac, text)
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
      meaning = if bracketed?(ac, text)
        get_meaning(ac, context.before.chomp('(').rstrip)
      else
        nil
      end
      ############################################################################################
      # CREATE ACRONYM
      ############################################################################################
      # If the meaning has been learnt from the text, it is put into the database
      # If not, when the list is displayed, we'll try and match it with the chosen dictionary
      self.acronyms.push Acronym.create(initialism: ac, context_before: context.before, context_after: context.after, bracketed: bracketed?(ac, text),
        bracketed_on_first_use: bracketed_on_first_use?(ac, text), meaning: meaning)
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

  def location_of_bracketed(ac, text) # index of first bracketed instance
    loc = (text =~ /\(#{ac}\)/)
    return loc+1 if loc # The regexg will show the location of the parethesis
    nil
  end

  def location_of_first_use(ac, text)
    text =~ /\b#{ac}\b/
  end

  def get_index(ac, text)
    if bracketed?(ac, text)
      location_of_bracketed(ac, text)
    else
      location_of_first_use(ac, text)
    end
  end

  def bracketed_on_first_use?(ac, text) # Is the acronym in brackets the first time it appears?
    text =~ /.#{ac}./ # first match
    ($1 == "(#{ac})")
  end

  def bracketed?(ac, text) # Does the text contain the acronym in brackets anywhere?
    # Also check singular?
    !!location_of_bracketed(ac, text)
  end

  def get_context(ac, text)
    index = get_index(ac, text) # returns char 2 before acronym if bracketed
    
    raise "#{ac} not found" unless index

    start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
    finish = (index + ac.length + CONTEXT) > text.length ? text.length : index + ac.length + CONTEXT

    #binding.pry

    Context.new( text[start...index],
      text[(index+ac.length)...finish]
    )
  end

  def get_singular(ac) # Get the singular version
    if ac =~ /(.*)s$/ then $1 else ac end
  end

  def get_meaning(ac, previous_text)
    # If ac is plural, then kill the final s before searching for the longhand
    # because MDAs doesn't expand as M*** D** A***** S**.
    incidentals = %W( for in of and )
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
    divider = '[\s\-]' # Old skool - works, but is limited
    #divider = '[\s\-]+' # trying to catch garbled "public - private partnership"
    word = '\w+' #"\w{1,#{maximum_word_length}"
    case_sensitivity = Regexp::IGNORECASE # right more often than not?
    previous_text = previous_text.rstrip
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
    #binding.pry
    if previous_text =~ definition_regexp
      meaning = $&
      @guesslog.info { "Matched '#{singular}' with '#{meaning}'" }
    else
      text_to_log = 40
      shortened_text = previous_text.length > text_to_log ? previous_text[-text_to_log..-1] : previous_text
      @guesslog.info { "Failed to match '#{singular} in '#{shortened_text}'"}
    end
    meaning
  end
end
