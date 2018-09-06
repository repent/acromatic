class AddMeaningToAcronym < ActiveRecord::Migration
  def change
    add_column :acronyms, :meaning, :string
  end
end
