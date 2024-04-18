class AddNewColumnsToInwardRemittance < ActiveRecord::Migration
  def change
    add_column :inward_remittances, :payeeVPA, :string rescue nil
    add_column :inward_remittances, :payerVPA, :string rescue nil
  end
end