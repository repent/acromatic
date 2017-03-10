class AddMeaningToDefinition < ActiveRecord::Migration
  def change
    add_column :definitions, :meaning, :string
  end
end
