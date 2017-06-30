class AddExcludeRomanToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :exclude_roman, :boolean
  end
end
