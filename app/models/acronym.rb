class Acronym < ActiveRecord::Base
  belongs_to :document
  include Comparable
  attr_reader :acronym

  # def initialize ac, context, bracketed, bracketed_on_first_use
    # @acronym,@context,@bracketed,@bracketed_on_first_use = ac,context,bracketed,bracketed_on_first_use
  # end

  # def ==(other)
  #   @acronym == other.acronym
  # end
  def <=>(other)
    @acronym <=> other.acronym
  end
  def letters
    @acronym
  end
end
