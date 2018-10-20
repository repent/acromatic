# == Schema Information
#
# Table name: dictionaries
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Dictionary < ActiveRecord::Base
  has_many :definitions, -> { order(initialism: :desc) }
  has_many :documents
  # Don't use commas because of definitions like ACP: Africa, Caribbean and Pacific group of countries
  DELIMITER = /[\t\;]/

  #def after_create
  #  binding.pry
  #end

  def include?(initialism)
    definitions.to_a.include? initialism
  end
  def to_s
    name
  end

  def lookup(initialism)
    # Returns zero or one result
    definition = definitions.find_by initialism: initialism
    definition ? definition.meaning : nil
  end

  # quick_add is a pseudo-field in dictionaries
  # "Get" quick_add field -- i.e. what to put in the form's text_area (nothing)
  def quick_add; end
  
  def quick_add=(data)
    data.lines.collect {|l| l.strip }.each do |def_line|
      if def_line =~ DELIMITER
        initialism,meaning = def_line.split DELIMITER
        unless include? initialism
          definitions.push Definition.new( initialism: initialism.strip, meaning: meaning.strip )
        end
      end
    end
  end

  def merge_duplicates
    duplicate_count = 0
    # initialism => [ definition1, definition2, ... ]
    definitions.group_by(&:initialism).each_pair do |i,d|
      # i=initialism
      # d=[ definitions ]
      logger.info "Comparing definitions of #{i}"
      next if d.length == 1 # only one listing of this initialism
      d.group_by(&:meaning).each_pair do |m,e|
        # m: meaning
        # e: [ deftinitions ]
        logger.info "Dealing with duplicates of #{i} = #{m}"
        e.pop # keep the first definition using this meaning
        # if any remain, they're duplicates
        e.each do |duplicate|
          duplicate_count += 1
          duplicate.destroy
        end
      end
    end
    return duplicate_count
  end

  def count_definitions(initialism)
    definitions.group_by(&:initialism)[initialism].length
  end
end
