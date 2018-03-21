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

class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  has_many :acronyms
  belongs_to :dictionary
  validates :file, presence: true

  CONTEXT = 60

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
      ac = ac[0]

      # Get the singular version
      singular = ac =~ /(.*)s$/ ? $1 : ac

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
      # Create chunks of CONTEXT for various purposes
      ############################################################################################
      # Use the first bracketed occurance, if it exists; otherwise, the first occurance
      # [Note that this is the same whether this is the first or tenth time this acronym has
      # been fount (EXCEPT FOR PLURALS), so no need to repeat this]
      location_of_bracketed = (text =~ /\(#{ac}\)/)
      # Does the text contain the acronym in brackets anywhere?
      bracketed = !!location_of_bracketed
      index = if bracketed
        location_of_bracketed
      else
        index = text =~ /\b#{ac}\b/
      end
      
      raise "#{ac} not found" unless index
      # TODO:
      # Now there is a glitch when the ac length is incorrectly measured because it is(n't) bracketed
      # e.g.: Adopt, Adapt, Expand, Respond AAERR) framework. This provides a way of
      #                                         ==
      start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
      finish = (index + CONTEXT) > text.length ? text.length : index + CONTEXT
      context_before = text[start...index] # used for display
      context_after  = text[(index+ac.length)...finish] # display
      ############################################################################################

      # Is the acronym in brackets the first time it appears?
      text =~ /.#{ac}./
      bracketed_on_first_use = ($1 == "(#{ac})")

      ############################################################################################
      # MEANING
      ############################################################################################
      # If the acronym appears in brackets, then try to figure out what it might mean
      # Stuff that gets in the way:
      #   incidental words, e.g. Business Environment for Economic Development
      #   punctuation, e.g. Adopt, Adapt, Expand, Respond; ministries, departments and agencies
      #   apostrophes, e.g. women's economic empowerment
      #   utter stupidity, e.g. making markets work for the poor
      meaning = nil
      @guesslog ||= Logger.new Rails.root.join 'log', 'guessing_meaning_of_acronyms.log'
      if bracketed
        # . does not match newlines, (and * is greedy) so this grabs the foregoing paragraph
        text =~ /(.*)\(#{ac}\)/ # first bracketed case
        previous_text = $1.rstrip # used to decode acronyms
        meaning = parse_meaning(singular, previous_text)
      end
      ############################################################################################

      # Perhaps this should be done on display rather on "trawl" --
      # then the dictionary can be changed after the document has been uploaded
      # Perhaps better for "meaning" not to be a db field of an acronym but a pseudo
      # built on demand from the current dictionary
      #meaning = dictionary ? dictionary.lookup(ac) : nil

      ############################################################################################
      # CREATE ACRONYM
      ############################################################################################
      # If the meaning has been learnt from the text, it is put into the database
      # If not, when the list is displayed, we'll try and match it with the chosen dictionary
      self.acronyms.push Acronym.create(initialism: ac, context_before: context_before, context_after: context_after, bracketed: bracketed,
        bracketed_on_first_use: bracketed_on_first_use, meaning: meaning)
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

  def parse_meaning(singular, previous_text)
    incidentals = %W( for in of and )
    #total_definition_length = 100
    #maximum_word_length = 12
    divider = '[\s\-]'
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
