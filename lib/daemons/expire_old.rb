ENV["APP_ROOT"] ||= File.expand_path("#{File.dirname(__FILE__)}/..")
ENV["RAILS_ENV_PATH"] ||= "#{ENV["APP_ROOT"]}/../config/environment.rb"

require ENV['RAILS_ENV_PATH']

#require File.join(File.expand_path(File.dirname(__FILE__)), '../../config/environment.rb')

loop do

  LINE = '='*80
  
  logger = Logger.new("#{ENV['APP_ROOT']}/../log/daemons.log")
  
  logger.info LINE
  logger.info "Running expire_old daemon at #{Time.now}"
  
  threshold = Time.now - 2.weeks
  
  logger.info "Destroying documents that are older than #{threshold}"
  logger.info LINE
  
  if Document.all.empty?
    logger.info "Database is empty"
  else
    Document.all.each do |d|
      if d.updated_at < threshold
        # full path: d.file.file.file
        # filename only: File.basename d.file_url
        binding.pry
        # error-proofing: seems that some document objects have been created with no file
        basename = d.file_url ? File.basename d.file_url : '[none]'
        if d.file_url
          logger.info "#{basename} (ID #{d.id}) is expired (last updated #{d.updated_at}),  deleting"
        d.delete
      else
        logger.debug "#{basename} (ID #{d.id}) is too recent to remove (last updated #{d. updated_at}), leaving"
      end
    end
  end
  
  logger.info LINE
  logger.info "Completed peacefully"
  logger.info LINE

  sleep 1.week
end
