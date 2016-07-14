class Acronym < ActiveRecord::Base
  belongs_to :document
  include Comparable

  # def initialize ac, context, bracketed, bracketed_on_first_use
    # @acronym,@context,@bracketed,@bracketed_on_first_use = ac,context,bracketed,bracketed_on_first_use
  # end

  # def ==(other)
  #   @acronym == other.acronym
  # end
  def <=>(other)
    self.initialism.to_s <=> other.initialism.to_s
  end
end
