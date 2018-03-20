# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  def to_text
    raise "docx2txt has not been installed" unless system('which docx2txt')
    #################################################################################
    # Document must end in .docx (case sensitive) in order for the old jiggery-pokery
    # to work
    # This is what docx2txt does:
    #   filename.docx --> filename.txt
    #   filename.DOCX --> filename.DOCX.txt
    #################################################################################

    # Usage:  /usr/bin/docx2txt [infile.docx|-|-h] [outfile.txt|-]
    #         /usr/bin/docx2txt < infile.docx
    #         /usr/bin/docx2txt < infile.docx > outfile.txt
    # 
    #         In second usage, output is dumped on STDOUT.
    # 
    #         Use '-h' as the first argument to get this usage information.
    # 
    #         Use '-' as the infile name to read the docx file from STDIN.
    # 
    #         Use '-' as the outfile name to dump the text on STDOUT.
    #         Output is saved in infile.txt if second argument is omitted.
    # 
    # Note:   infile.docx can also be a directory name holding the unzipped content
    #         of concerned .docx file.

    txt_path = current_path.sub(/docx$/i, 'txt')
    # Explicitly define destination because otherwise docx2txt is inconsistent
    # At this point the .docx is ONLY in public/uploads/tmp/
    `docx2txt < "#{current_path}" > "#{txt_path}"`
    # Still only in tmp
    File.rename txt_path, current_path
    # At some point after this, the two files get moved over to public/uploads/document/file/xxx
  end

  # Create different versions of your uploaded files:
  # version :thumb do
    # process resize_to_fit: [100, 100]
  # end

  version :text do
    process :to_text
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(docx)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
