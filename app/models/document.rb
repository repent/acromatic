class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
  has_many :acronyms

  def sweep_acronyms

    # Grab the text version of this document
    text = File.readlines(self.file.versions[:text].file.file).join
    
    # Doesn't catch ToR, LoE etc, which are bullshit but so, fundamentally, are all acronyms
    # text.scan(/[A-Z]{2,}/) do |ac|
    #   acronyms.push ac
    # end
    pattern = /[A-Z]{2,}/

    text.scan(pattern) do |ac|
      # puts ac
      # binding.pry
      index = text =~ /#{ac}/
      next unless self.acronyms.where(acronym: ac).empty? # skip if already recorded
      start = (index - 50) < 0 ? 0 : index - 50
      finish = (index + 50) > text.length ? text.length : index + 50
      context = text[start...finish]
      bracketed = !!(text =~ /\(#{ac}\)/)
      text =~ /.#{ac}./
      bracketed_on_first_use = ($1 == "(#{ac})")
      self.acronyms.push Acronym.create(acronym: ac, context: context, bracketed: bracketed,
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
