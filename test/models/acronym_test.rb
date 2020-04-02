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
#  meaning                :string
#  plural_only            :boolean
#  defined_in_plural      :boolean
#

require 'test_helper'

class AcronymTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
    # assert_not
    # available assertions: https://guides.rubyonrails.org/testing.html#the-test-environment
    # assert_raises(NameError) do
    #   some_undefined_variable
    # end
  end

  # initialism is always SINGULAR, so testing plurals is NOT ALLOWED

  test "should be able to tell whether it is mixed case" do
    #assert acronyms(:tor_mixed).mixedcase? == true
    #assert acronyms(:tor_uppercase).mixedcase? == false
    #assert acronyms(:tors_uppercase).mixedcase? == false
    #assert acronyms(:tors_mixedcase).mixedcase? == true
    assert  Acronym.new(initialism: 'ToR').mixedcase?
    assert  Acronym.new(initialism: 'FARTy').mixedcase?
    assert !Acronym.new(initialism: 'TOR').mixedcase?
    assert  Acronym.new(initialism: 'yURT').mixedcase?
  end
  test "should know if it contains hyphens ampersands or plus signs" do
    assert  Acronym.new(initialism: 'IS-LM').hyphens?
    assert !Acronym.new(initialism: 'ISLM').hyphens?
    assert  Acronym.new(initialism: 'AB-').hyphens?
    assert  Acronym.new(initialism: 'S&DT').hyphens?
    assert  Acronym.new(initialism: 'S+DT').hyphens?
    assert  Acronym.new(initialism: 'TAF2+').hyphens?
    assert  Acronym.new(initialism: 'PACER+').hyphens?
  end
  test "should know if it contains numbers" do
    assert  Acronym.new(initialism: 'A4T').numbers?
    assert !Acronym.new(initialism: 'AFT').numbers?
    assert  Acronym.new(initialism: 'ISO9001').numbers?
    assert  Acronym.new(initialism: '1TO1').numbers?
  end
  test "should know if it is short" do
    assert  Acronym.new(initialism: 'AA').short?
    assert !Acronym.new(initialism: 'FAB').short?
    #assert  Acronym.new(initialism: 'AAs').short?
    #assert !Acronym.new(initialism: 'FABs').short?
  end
  test "should know if its a roman numeral" do
    assert  Acronym.new(initialism: 'IV').roman?
    assert  Acronym.new(initialism: 'CXI').roman?
    assert !Acronym.new(initialism: 'VIV').roman?
    assert !Acronym.new(initialism: 'XIVII').roman?
  end  
end
