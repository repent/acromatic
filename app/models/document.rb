class Document < ActiveRecord::Base
  mount_uploader :file, FileUploader
end
