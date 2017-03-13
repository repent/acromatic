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
  has_many :definitions
  has_many :documents
  # Don't use commas because of definitions like ACP: Africa, Caribbean and Pacific group of countries
  DELIMITER = /[\t\;]/

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
end
