class CreateAcronyms < ActiveRecord::Migration
  def change
    create_table :acronyms do |t|
      t.string :acronym
      t.text :context
      t.boolean :bracketed
      t.boolean :bracketed_on_first_use

      t.timestamps null: false
    end
  end
end
