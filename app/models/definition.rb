# == Schema Information
#
# Table name: definitions
#
#  id            :integer          not null, primary key
#  dictionary_id :integer
#  initialism    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  meaning       :string
#

class Definition < ActiveRecord::Base
  belongs_to :dictionary

  validates :initialism, length: {minimum: 2}
  validates :meaning, length: {minimum: 2}
  validates :dictionary, presence: true

  def <=>(other)
    initialism.to_s.downcase <=> other.to_s.downcase
  end
  def to_s
    initialism
  end
end
