class AddDictionaryToDocuments < ActiveRecord::Migration
  def change
    add_reference :documents, :dictionary, index: true, foreign_key: true
  end
end

#def change
#  add_reference :acronyms, :document, index: true, foreign_key: true
#end