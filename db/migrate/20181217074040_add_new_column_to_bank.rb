class AddNewColumnToBank < ActiveRecord::Migration
  def change
    add_column :banks, :upi_enabled, :string, limit: 1, :null => false, :default => 'Y', comment: 'the flag which indicates whether this bank is upi enabled or not'
  end rescue nil
end