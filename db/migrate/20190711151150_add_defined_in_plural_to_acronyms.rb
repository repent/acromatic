class AddDefinedInPluralToAcronyms < ActiveRecord::Migration
  def change
    add_column :acronyms, :defined_in_plural, :boolean
  end
end
