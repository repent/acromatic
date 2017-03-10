# == Schema Information
#
# Table name: acronyms
#
#  id                     :integer          not null, primary key
#  initialism             :string
#  bracketed              :boolean
#  bracketed_on_first_use :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  document_id            :integer
#  context_before         :text
#  context_after          :text
#

require 'test_helper'

class AcronymTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
