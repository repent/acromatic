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
#  dictionary      :has_one
#

# to refresh run annotate

class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  has_many :acronyms
  belongs_to :dictionary
  validates :file, presence: true

  CONTEXT = 60

  def trawl
    # Grab the text version of this document
    text = File.readlines(self.file.versions[:text].file.file).join
    
    # Doesn't catch ToR, LoE etc, which are bullshit but so, fundamentally, are all acronyms
    # text.scan(/[A-Z]{2,}/) do |ac|
    #   acronyms.push ac
    # end
    #pattern = /\b[A-Z]{2,}\b/ # restrictive
    #pattern = /\b([A-Z,0-9][A-z,0-9,-]+[A-Z,0-9](s)?)\b/ # liberal, 3-letter minimum, can start with number
    pattern = /\b([A-Z][A-z,0-9,-]*[A-Z,0-9](s)?)\b/ # liberal, 2-letter minimum, must start with letter
    #internal_lowercase,plurals,hyphens,numbers=false,false,false,false

    text.scan(pattern) do |ac|
      # if pattern contains grouts (with parentheses) then each ac will be an array
      ac = ac[0]

      # To do (here and above):
      #   Allow rescanning with different parsing options:
      #    ending in s (TORs)
      #    internal lower case (AusAID)
      #    internal hyphen (BIG-T)
      #    numbers (BICF2)

      # Prepare fields before the Acronym is created

      # Context
      # Early version: context contains the acronym, with some sort of markup junk already in there
      # New version: context_before and context_after contain raw text only (maybe strip weird white space?)
      #   Markup can therefore be added when displayed, according to preferences

      # May want to allow plurals here even if they are not generally allowed?
      index = text =~ /\b#{ac}\b/
      raise "#{ac} not found" unless index
      next unless self.acronyms.where(initialism: ac).empty? # skip if already recorded

      start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
      finish = (index + CONTEXT) > text.length ? text.length : index + CONTEXT
      # Old process
      #context = text[start...finish]
      # New process
      context_before = text[start...index]
      context_after  = text[(index+ac.length)...finish]

      # Old
      # Would be nice to make the acronym stand out in the context, even if just usind md *s
      # context = "#{$`.last(CONTEXT)}<span class=\"acronym\">#{$~}</span>#{$'.first(CONTEXT)}"

      # Other fields: bracketed, bracketed_on_first_use
      # Does the text contain the acronym in brackets anywhere?
      bracketed = !!(text =~ /\(#{ac}\)/)
      # Is the acronym in brackets the first time it appears?
      text =~ /.#{ac}./
      bracketed_on_first_use = ($1 == "(#{ac})")

      #binding.pry
      # Perhaps this should be done on display rather on "trawl" --
      # then the dictionary can be changed after the document has been uploaded
      # Perhaps better for "meaning" not to be a db field of an acronym but a pseudo
      # built on demand from the current dictionary
      #meaning = dictionary ? dictionary.lookup(ac) : nil

      # Create Acronym
      # Old
      #self.acronyms.push Acronym.create(initialism: ac, context: context, bracketed: bracketed,
      #  bracketed_on_first_use: bracketed_on_first_use)
      # New
      self.acronyms.push Acronym.create(initialism: ac, context_before: context_before, context_after: context_after, bracketed: bracketed,
        bracketed_on_first_use: bracketed_on_first_use )#, meaning: meaning)
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

  #def dictionary_id
  #  dictionary.id
  #end

  #def find_definition(ac)
  #  search_term = Regexp.new ac.chars.collect{ |c| "#{c}\w?" }.join('\s')
  #  all = search_term.match(text).to_a
  #end
end
