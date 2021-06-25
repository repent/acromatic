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
  test "infer acronym meaning from text" do
    # 6.21: incidentals = %W( for in of and )
    d = Document.new
    assert_equal 'all about cows', d.get_meaning('AAC', "I am all about cows ")
    assert_equal 'on the run', d.get_meaning('OTR', "everyone is on the run")
    assert_equal 'all your base', d.get_meaning('AYB', " we belong all your and base ")
    assert_equal 'my first time', d.get_meaning('MFT', " my of first and time")
    assert_equal 'all if cheese', d.get_meaning('AIC', " all the if of cheese")
  end
end
