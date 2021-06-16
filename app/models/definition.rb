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

  # Top level sort: auto-mergeables, conflicts, uniques
  # Second: initialism
  # Third: meaning
  def <=>(other)
    # Bump one to the surface if it is conflicted and the other isn't
    #return -1 if (conflicted? and !other.conflicted?)
    #return  1 if (!conflicted? and other.conflicted?)
    comparison = (sort_level <=> other.sort_level)
    return comparison unless comparison == 0
    # Next sort by initialism, then meaning
    comparison = (initialism.downcase <=> other.initialism.downcase)
    return comparison unless comparison == 0
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
      next if id == definition.id # don't compare with self
      return true if identical_to?(definition)
    end
    false
  end

  def css_id
    if conflicted?
      if duplicate?
        'duplicate'
      else
        'conflicted'
      end
    else
      'unique'
    end
  end
  def sort_level
    return 0 if duplicate?
    return 1 if conflicted?
    return 2
  end

  def sentence_case!
    self.meaning = self.meaning.humanize
    self.save!
  end

  def titlecase!
    self.meaning = self.meaning.titlecase
    self.save!
  end

  private
  def identical_to?(other)
    raise "Comparison with self makes no sense" if id == other.id
    return ((initialism == other.initialism) and (meaning == other.meaning))
  end
end
