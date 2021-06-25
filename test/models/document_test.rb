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
  d = Document.new

  test_cases = [
    [ 'all about cows', 'AAC',  "I am all about cows " ],
    [ 'on the run',     'OTR',  "everyone is on the run" ],
    [ 'all your base',  'AYB',  " we belong all your and base " ],
    [ 'my first time',  'MFT',  " my of first and time" ],
    [ 'all if cheese',  'AIC',  " all the if of cheese" ],
    [ "physician's assistants", "PA", " Department for processing. After the physician's assistants" ],
    [ "Papua New Guinea", "PNG", "vessels that fish in Papua New Guinea's" ],
    [ "Kiribati Fish Ltd.", 'KFL', 'requires 30% of all yellowfin be landed to Kiribati Fish Ltd.' ],
    # Incidentals
    [ "College of American Pathologists", 'CAP', 'ional Requirements of the College of American Pathologists' ],
    [ "all the way home", "AWH", "I don't know how we'd ever manage to get all the way home"],
    # Plurals
    [ 'all about cows', 'AACs',  "I am all about cows " ],
    [ 'on the runs',    'OTRs',  "everyone is on the runs" ],
  ]

  test_cases.each do |answer, ac, st|
    # 6.21: incidentals = %W( for in of and )
    test "infer meaning of acronym #{ac} from text" do
      assert_equal answer, d.get_meaning( ac, st )
    end
    # assert_equal 'all about cows', d.get_meaning('AAC', "I am all about cows ")
    # assert_equal 'on the run', d.get_meaning('OTR', "everyone is on the run")
    # assert_equal 'all your base', d.get_meaning('AYB', " we belong all your and base ")
    # assert_equal 'my first time', d.get_meaning('MFT', " my of first and time")
    # assert_equal 'all if cheese', d.get_meaning('AIC', " all the if of cheese")
  end

  # Gotchas:
  #   Acronym can't be at the start of the string (or the very start of the document)

  search_text = [
    [ 'get the AC working', 'AC' ],
    [ 'Never mind the old • IOTC–2018–S22–R[E]. 114 p., it is nuts', 'IOTC' ],
    [ 'What about the PICs- and all that?', 'PICs' ],
    [ "\nPACER+ ftl!", 'PACER+' ],
    [ "Our priority is S+DT, isn't it?", "S+DT"],
    [ "Our priority is S&DT, isn't it?", "S&DT"],
    [ 'Are we talking CamelCase or AusAID? ', 'AusAID' ],
    [ 'Are you still using IS-LM to model that toaster?', 'IS' ],
    [ 'What about a programme like BICF2, would that work?', 'BICF2' ],
    [ "What is the deal with TAF2+ these days?", "TAF2+" ],
    [ "Go go go USA2024!", "USA2024" ],
    # Plurals
    [ 'Do you have a copy of the ToRs?', 'ToRs' ],
    #[ '', '' ],
  ]

  search_text.each do |st, answer|
    test "find #{answer} in sample search text" do
      assert_equal answer, d.find_first(st)
    end
  end
end
