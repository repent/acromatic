class RenameAcronymInAcronym < ActiveRecord::Migration
  def change
    rename_column :acronyms, :acronym, :initialism
  end
end
