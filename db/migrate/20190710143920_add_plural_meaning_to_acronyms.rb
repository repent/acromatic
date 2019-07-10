class AddPluralMeaningToAcronyms < ActiveRecord::Migration
  def change
    add_column :acronyms, :plural_meaning, :string
  end
end
