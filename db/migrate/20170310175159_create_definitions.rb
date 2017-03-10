class CreateDefinitions < ActiveRecord::Migration
  def change
    create_table :definitions do |t|
      t.belongs_to :dictionary, index: true, foreign_key: true
      t.string :initialism

      t.timestamps null: false
    end
  end
end
