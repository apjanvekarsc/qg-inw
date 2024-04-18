class AddOrRemoveColumnsInInwardRemittance < ActiveRecord::Migration
  def change
    return nil if Rails.env.production?
    add_column :inward_remittances, :PAYERVPA, :string rescue nil
    add_column :inward_remittances, :PAYEEVPA, :string rescue nil
    remove_column :inward_remittances, :payeeVPA, :string rescue nil
    remove_column :inward_remittances, :payerVPA, :string rescue nil
  end
end