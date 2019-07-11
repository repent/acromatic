class AddPluralOnlyToAcronyms < ActiveRecord::Migration
  def change
    add_column :acronyms, :plural_only, :boolean
  end
end
