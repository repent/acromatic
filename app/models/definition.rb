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
    # Bump one to the surface if it is conflicted and the other isn't
    return -1 if (conflicted? and !other.conflicted?)
    return  1 if (!conflicted? and other.conflicted?)
    # Next sort by initialism, then meaning
    return (initialism.downcase <=> other.initialism.downcase) unless 0 == (initialism.downcase <=> other.initialism.downcase)
    meaning.downcase <=> other.meaning.downcase
  end

  def to_s
    initialism
  end
  def conflicted? # true if this dictionary has another instance of this initialism (regardless of whether the meanings are the same)
    #true
    dictionary.count_definitions(initialism) > 1
  end
  def duplicate? # true if there is another Definition with same initialism, same meaning
    dictionary.definitions.each do |definition|
      return true if self == definition
    end
    false
  end
  def css_id
    conflicted? ? 'conflicted' : 'unique'
  end
end
