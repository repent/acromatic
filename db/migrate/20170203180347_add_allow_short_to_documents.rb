class AddAllowShortToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :allow_short, :boolean
  end
end
