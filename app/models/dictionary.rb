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
end
