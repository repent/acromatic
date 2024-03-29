# == Schema Information
#
# Table name: acronyms
#
#  id                     :integer          not null, primary key
#  initialism             :string
#  bracketed              :boolean
#  bracketed_on_first_use :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  document_id            :integer
#  context_before         :text
#  context_after          :text
#  meaning                :string
#  plural_only            :boolean
#  defined_in_plural      :boolean
#

# to refresh run annotate

class Acronym < ActiveRecord::Base
  belongs_to :document
  include Comparable

  ROMAN_MAP = { 1000 => 'M' ,
                 900 => 'CM',
                 500 => 'D' ,
                 400 => 'CD',
                 100 => 'C' ,
                  90 => 'XC',
                  50 => 'L' ,
                  40 => 'XL',
                  10 => 'X' ,
                   9 => 'IX',
                   5 => 'V' ,
                   4 => 'IV',
                   1 => 'I',
              }.freeze
  ROMAN_NUMERALS = Array.new(3999) do |index|
    target = index + 1
    ROMAN_MAP.keys.sort { |a,b| b <=> a }.inject("") do |roman, div|
      times, target = target.divmod(div)
      roman << ROMAN_MAP[div] * times
    end
  end.freeze

  # def initialize ac, context, bracketed, bracketed_on_first_use
    # @acronym,@context,@bracketed,@bracketed_on_first_use = ac,context,bracketed,bracketed_on_first_use
  # end

  # def ==(other)
  #   @acronym == other.acronym
  # end
  def <=>(other)
    # Ruby puts B before a, so use downcase.
    self.initialism.downcase.to_s <=> other.initialism.downcase.to_s
  end
  # A pseudo-field, generated on demand using the current dictionary
  # ...if not available
  def find_meaning
    return meaning unless meaning.blank? # '' or nil
    if document and document.dictionary
      document.dictionary.lookup(initialism)
    else
      nil
    end
  end
  def has_meaning?
    meaning or !!find_meaning
  end

  def mixedcase?
    !!(self.initialism.chomp('s') =~ /[a-z]/)

    # OLD: initialism used to be guaranteed singular, that is not the case any more and it
    # would be better for this method not to care anyway
    # initialism is always singular, even if the acronym does not appear in singular
    # so this test does not need to worry about a trailing s; this should never be present
    # !!(self.initialism =~ /[a-z]/)

    # OLD: (trying to cope with potential plurals)
    # Either a non-s lower case letter or an s followed by another character
    # &&: intersection of 2 character classes
    #self.initialism =~ /[a-r,t-z]/ or self.initialism =~ /s./
    #self.initialism =~ /[a-z&&^s]/ or self.initialism =~ /s./
  end
  def plurals?
    self.plural_only
  end
  def hyphens? # or ampersands, or plus signs
    #self.initialism =~ /[\-\&\+]/
    # internal hyphens and plus signs cause problems
    self.initialism =~ /[\&\+]/
  end
  def numbers?
    self.initialism =~ /[0-9]/
  end
  def short?
    self.initialism.length == 2
  end
  def roman?
    #self.initialism =~ /[IVXLCDM]+/
    ROMAN_NUMERALS.include? self.initialism
  end

  def allowed?()
    if ( ( !document.allow_mixedcase and mixedcase? ) ||
         ( !document.allow_plurals   and plurals?   ) ||
         ( !document.allow_hyphens   and hyphens?   ) ||
         ( !document.allow_numbers   and numbers?   ) ||
         ( !document.allow_short     and short?     ) ||
         (  document.exclude_roman   and roman?    ))
      return false
    else
      return true
    end
  end

  def context(options={}) # now a fake attribute, made of context_before, context_after and sugar
    central_text = initialism
    if options[:search_link] then central_text = search_link end
    if options[:css] then central_text = '<span class="acronym">' + central_text + '</span>' end
    context_before + central_text + context_after
  end

  def markup
    "<span class='acronym'>#{search_link}</span>".html_safe
  end

  def meaning_with_initial_capital
    if meaning and !meaning.empty?
      meaning[0].upcase + meaning[1..-1]
    else
      find_meaning
    end
  end

  def initialism_for_list
    plural_only || defined_in_plural ? initialism + 's' : initialism
  end

  private
  def search_link(text=self.initialism_for_list)
    # www.acronymfinder.com/#{initialism}.html
    # acronyms.thefreedictionary.com/#{initialism}
    %Q{<a href="https://duckduckgo.com/?q=#{initialism}" target="_blank">#{text}</a>}
  end

  def roman_to_i(roman)
    raise "Invalid roman numeral" unless roman =~ /^[IVXLCDM]+$/
    # We're particularly interested in catching errors; check big numbers don't show up after small
    # ones
    level = 1000
    i = 0
    ROMAN.each do |l|
      if roman =~ /^#{l.letter}(.*)$/
        puts "level: #{level}, l.int: #{l.int}"
        raise "Invalid roman numeral" unless l.int <= level
        level = l.int
        i += l.int
        roman = $1
      end
    end
    return i
  end

  def singular
    initialism[-1] == 's' ? initialism[0...-1] : initialism
  end
end
