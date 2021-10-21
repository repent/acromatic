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
require 'pry'

class DocumentTest < ActiveSupport::TestCase

  d = Document.new

  test_cases = [
    [ 'all about cows', 'AAC',  "I am all about cows " ],
    [ 'on the run',     'OTR',  "everyone is on the run" ],
    [ 'all your base',  'AYB',  " we belong all your and base " ],
    [ 'my first time',  'MFT',  " my of first and time" ],
    [ 'all if cheese',  'AIC',  " all the if of cheese" ],
    # [ "physician's assistant", "PA", " Department for processing. After the physician's assistants" ],
    # [ "College of American Pathologists", 'CAP', 'ional Requirements of the College of American Pathologists' ],
    # [ "Papua New Guinea", "PNG", "vessels that fish in Papua New Guinea's" ],
  ]

  # get_meaning (private) has changed (context is now an object not a string);
  # this is the old behaviour:

  # test_cases.each do |answer, ac, st|
  #   # 6.21: incidentals = %W( for in of and )
  #   test "infer meaning of acronym #{ac} from text" do
  #     assert_equal answer, d.get_meaning( ac, st )
  #   end
  #   # assert_equal 'all about cows', d.get_meaning('AAC', "I am all about cows ")
  #   # assert_equal 'on the run', d.get_meaning('OTR', "everyone is on the run")
  #   # assert_equal 'all your base', d.get_meaning('AYB', " we belong all your and base ")
  #   # assert_equal 'my first time', d.get_meaning('MFT', " my of first and time")
  #   # assert_equal 'all if cheese', d.get_meaning('AIC', " all the if of cheese")
  # end

  test_cases.each do |answer, ac, st|
    # 6.21: incidentals = %W( for in of and )
    test "infer meaning of acronym #{ac} from text" do
      context = Document::Context.new(st, '')
      assert_equal answer, d.get_meaning( ac, context )
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
    [ 'What about the PICs- and all that?', 'PIC' ],
    [ "\nPACER+ ftl!", 'PACER+' ],
    [ "Our priority is S+DT, isn't it?", "S+DT"],
    [ "Our priority is S&DT, isn't it?", "S&DT"],
    [ 'Do you have a copy of the ToRs?', 'ToR' ],
    [ 'Are we talking CamelCase or AusAID? ', 'AusAID' ],
    [ 'Are you still using IS-LM to model that toaster?', 'IS' ],
    [ 'What about a programme like BICF2, would that work?', 'BICF2' ],
    [ "What is the deal with TAF2+ these days?", "TAF2+" ],
    [ "Go go go USA2024!", "USA2024" ],
    #[ '', '' ],
  ]

  search_text.each do |st, answer|
    test "find #{answer} in sample search text" do
      assert_equal answer, d.find_first(st)
    end
  end

  textfile_path = 'test/textfiles'
  answer_path = 'test/answers'

  source_textfiles = Dir.new(textfile_path).children.map do |f|
    [f, File.readlines(File.join(textfile_path, f)).join]
  end

  require 'yaml'

  expected_findings = Dir.new(answer_path).children.map do |f|
    YAML.load(File.readlines(File.join(answer_path, f)).join)
  end

  #expected_findings = Dir.new('results').children.map do |f|

  source_textfiles.zip(expected_findings).each do |(filename, text), answers|
    test "each_acronym finds something roughly sensible for #{filename}" do
      d.each_acronym(text) do |ac, plural, context|
        assert( (plural == true or plural == false) )
        assert_kind_of( Document::Context, context )
        # context.each do |c|
        #   # If there is an acronym near the start or end of the document,
        #   # context will be truncated
        #   assert(c.length.between?(50, 70))
        # end
      end
    end

    test "all acronyms in #{filename} are found" do
      d = Document.create()
      d.trawl(text)
      assert_equal answers, d.initialisms
    end
  end
end
