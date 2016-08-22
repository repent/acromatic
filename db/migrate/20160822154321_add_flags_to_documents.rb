class AddFlagsToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :allow_mixedcase, :boolean, default: false
    add_column :documents, :allow_plurals, :boolean, default: false
    add_column :documents, :allow_hyphens, :boolean, default: false
    add_column :documents, :allow_numbers, :boolean, default: false
  end
end
