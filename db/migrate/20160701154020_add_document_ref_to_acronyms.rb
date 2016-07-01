class AddDocumentRefToAcronyms < ActiveRecord::Migration
  def change
    add_reference :acronyms, :document, index: true, foreign_key: true
  end
end
