class ChangeContextToTwoPartsInAcronym < ActiveRecord::Migration
  def up
    add_column :acronyms, :context_before, :text
    add_column :acronyms, :context_after, :text
    remove_column :acronyms, :context
  end
  def down
    remove_column :acronyms, :context_before
    remove_column :acronyms, :context_after
    add_column :acronyms, :context, :text
  end
end
