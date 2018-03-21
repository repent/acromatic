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
#

# to refresh run annotate

class Acronym < ActiveRecord::Base
  belongs_to :document
  include Comparable

  #Roman = Struct.new(:letter, :int)
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
              }
  ROMAN_NUMERALS = Array.new(3999) do |index|
    target = index + 1
    ROMAN_MAP.keys.sort { |a,b| b <=> a }.inject("") do |roman, div|
      times, target = target.divmod(div)
      roman << ROMAN_MAP[div] * times
    end
  end

  # def initialize ac, context, bracketed, bracketed_on_first_use
    # @acronym,@context,@bracketed,@bracketed_on_first_use = ac,context,bracketed,bracketed_on_first_use
  # end

  # def ==(other)
  #   @acronym == other.acronym
  # end
  def <=>(other)
    self.initialism.to_s <=> other.initialism.to_s
  end
  # Return blank string rather than nil
  # This creates an infinite loop, obviously
  #ef meaning
  # meaning || ''
  #nd
  # Now a pseudo-field, generated on demand using the current dictionary
  def meaning
    if document and document.dictionary
      document.dictionary.lookup(initialism)
    else
      nil
    end
  end
  def meaning?
    !!meaning
  end

  def mixedcase?
    # If mixed case is banned but plurals are allowed, the acronym should be permitted to end in 's'
    # This incorrectly finds that ToRs is not mixed case.
    #self.initialism =~ /[a-z]/ and !(self.initialism =~ /[A-Z,0-9][A-Z,0-9,-]+[A-Z,0-9]s$/)
    # Either a non-s lower case letter or an s followed by another character
    self.initialism =~ /[a-r,t-z]/ or self.initialism =~ /s./
  end
  def plurals?
    self.initialism =~ /s$/
  end
  def hyphens?
    self.initialism =~ /\-/
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

  def allowed?() # allow_mixedcase: false, allow_plurals: false, allow_hyphens: false, allow_numbers: false)
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

  private
  def search_link(text=self.initialism)
    # www.acronymfinder.com/#{initialism}.html
    # acronyms.thefreedictionary.com/#{initialism}
    %Q{<a href="https://duckduckgo.com/?q=#{initialism}" target="_blank">#{text}</a>}
  end

  def roman_to_i(roman)
    raise "Invalid roman numeral" unless roman =~ /^[IVXLCDM]+$/
    level = 1000 # We're particularly interested in catching errors; check big numbers don't show up after small ones
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
  #def find_definition_of(ac)
  #  search_term = Regexp.new 
  #end
end

#    pattern =
#    if internal_lowercase
#      if plurals
#        if hyphens
#          if numbers
#            /\b[A-Z,0-9,-][A-z,0-9,-]+[A-Z,0-9,-](s)?\b/
#          else
#            /\b[A-Z,-][A-z,-]+[A-Z,-](s)?\b/
#          end
#        else
#          if numbers
#            /\b[A-Z,0-9][A-z,0-9]+[A-Z,0-9](s)?\b/
#          else
#            /\b[A-Z][A-Z]+[A-Z](s)?\b/
#          end
#        end
#      else
#        if hyphens
#          if numbers
#            /\b[A-Z,0-9,-][A-z,0-9,-]+[A-Z,0-9,-]\b/
#          else
#            /\b[A-Z,-][A-z,-]?[A-Z,-]\b/
#          end
#        else
#          if numbers
#            /\b[A-Z,0-9][A-z,0-9]+[A-Z,0-9]\b/
#          else
#            /\b[A-Z][A-z]+[A-Z]\b/
#          end
#        end
#      end
#    else
#      if plurals
#        if hyphens
#          if numbers
#            /\b[A-Z,0-9,-](s)?{2,}\b/
#          else
#            /\b[A-Z,-]{2,}(s)?\b/
#          end
#        else
#          if numbers
#            /\b[A-Z,0-9]{2,}(s)?\b/
#          else
#            /\b[A-Z]{2,}(s)?\b/
#          end
#        end
#      else
#        if hyphens
#          if numbers
#            /\b[A-Z,0-9,-]{2,}\b/
#          else
#            /\b[A-Z,-]{2,}\b/
#          end
#        else
#          if numbers
#            /\b[A-Z,0-9]{2,}\b/
#          else
#            /\b[A-Z]{2,}\b/
#          end
#        end
#      end
#    end
