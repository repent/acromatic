# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  file       :string
#

class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  has_many :acronyms

  CONTEXT = 60

  def trawl
    # Grab the text version of this document
    text = File.readlines(self.file.versions[:text].file.file).join
    
    # Doesn't catch ToR, LoE etc, which are bullshit but so, fundamentally, are all acronyms
    # text.scan(/[A-Z]{2,}/) do |ac|
    #   acronyms.push ac
    # end
    pattern = /\b[A-Z]{2,}\b/

    internal_lowercase,plurals,hyphens,numbers=false,false,false,false

    pattern =
    if internal_lowercase
      if plurals
        if hyphens
          if numbers
            /\b[A-Z,0-9,-][A-z,0-9,-]+[A-Z,0-9,-](s)?\b/
          else
            /\b[A-Z,-][A-z,-]+[A-Z,-](s)?\b/
          end
        else
          if numbers
            /\b[A-Z,0-9][A-z,0-9]+[A-Z,0-9](s)?\b/
          else
            /\b[A-Z][A-Z]+[A-Z](s)?\b/
          end
        end
      else
        if hyphens
          if numbers
            /\b[A-Z,0-9,-][A-z,0-9,-]+[A-Z,0-9,-]\b/
          else
            /\b[A-Z,-][A-z,-]?[A-Z,-]\b/
          end
        else
          if numbers
            /\b[A-Z,0-9][A-z,0-9]+[A-Z,0-9]\b/
          else
            /\b[A-Z][A-z]+[A-Z]\b/
          end
        end
      end
    else
      if plurals
        if hyphens
          if numbers
            /\b[A-Z,0-9,-](s)?{2,}\b/
          else
            /\b[A-Z,-]{2,}(s)?\b/
          end
        else
          if numbers
            /\b[A-Z,0-9]{2,}(s)?\b/
          else
            /\b[A-Z]{2,}(s)?\b/
          end
        end
      else
        if hyphens
          if numbers
            /\b[A-Z,0-9,-]{2,}\b/
          else
            /\b[A-Z,-]{2,}\b/
          end
        else
          if numbers
            /\b[A-Z,0-9]{2,}\b/
          else
            /\b[A-Z]{2,}\b/
          end
        end
      end
    end

    text.scan(pattern) do |ac|
      # To do (here and above):
      #   Allow rescanning with different parsing options:
      #    ending in s (TORs)
      #    internal lower case (AusAID)
      #    internal hyphen (BIG-T)
      #    numbers (BICF2)

      index = text =~ /\b#{ac}(s)?\b/
      raise "#{index} not found" unless index
      next unless self.acronyms.where(initialism: ac).empty? # skip if already recorded
      start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
      finish = (index + CONTEXT) > text.length ? text.length : index + CONTEXT
      context = text[start...finish]

      # Would be nice to make the acronym stand out in the context, even if just usind md *s
      context = "#{$`.last(CONTEXT)}<span class=\"acronym\">#{$~}</span>#{$'.first(CONTEXT)}"
      # context =~ /^[^\s]*\s(.*)\s[^\s]*$/
      # context = $1
      # context.gsub! ac, "**#{ac}**"
      bracketed = !!(text =~ /\(#{ac}\)/)
      text =~ /.#{ac}./
      bracketed_on_first_use = ($1 == "(#{ac})")
      self.acronyms.push Acronym.create(initialism: ac, context: context, bracketed: bracketed,
        bracketed_on_first_use: bracketed_on_first_use)
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

end
