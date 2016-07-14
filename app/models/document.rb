class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  has_many :acronyms

  CONTEXT = 100

  def trawl
    # Grab the text version of this document
    text = File.readlines(self.file.versions[:text].file.file).join
    
    # Doesn't catch ToR, LoE etc, which are bullshit but so, fundamentally, are all acronyms
    # text.scan(/[A-Z]{2,}/) do |ac|
    #   acronyms.push ac
    # end
    pattern = /[A-Z]{2,}/

    text.scan(pattern) do |ac|
      index = text =~ /#{ac}/
      next unless self.acronyms.where(initialism: ac).empty? # skip if already recorded
      start = (index - CONTEXT) < 0 ? 0 : index - CONTEXT
      finish = (index + CONTEXT) > text.length ? text.length : index + CONTEXT
      # Would be nice to make the acronym stand out in the context, even if just usind md *s
      context = text[start...finish]
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
