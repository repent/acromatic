class AddGuessMeaningsToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :guess_meanings, :boolean
  end
end
