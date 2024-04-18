class ModifyColumnLengthForInwardRemittances < ActiveRecord::Migration
  def change
    change_column :inward_remittances, :rmtr_code, :string, :limit => 50
    change_column :whitelisted_identities, :rmtr_code, :string, :limit => 50   
  end
end
