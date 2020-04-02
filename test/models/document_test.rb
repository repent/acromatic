# == Schema Information
#
# Table name: documents
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  file            :string
#  allow_mixedcase :boolean          default(FALSE)
#  allow_plurals   :boolean          default(FALSE)
#  allow_hyphens   :boolean          default(FALSE)
#  allow_numbers   :boolean          default(FALSE)
#  allow_short     :boolean
#  dictionary_id   :integer
#  exclude_roman   :boolean
#  guess_meanings  :boolean
#

require 'test_helper'
#require 'ruby-debug' # if ENV['DEBUG']

class DocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  #test "find an acronym" do
  #  finds = "Search this sentence FOR an acronym.".scan(Document.pattern)
  #  assert finds[0] == 'FOR'
  #  byebug
  #end
end
