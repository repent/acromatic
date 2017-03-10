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

require 'test_helper'

class DefinitionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
