class AddNewColumnsToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :allow_upi, :string, :limit=> 1, default: 'N' rescue nil
    add_column :partners, :validate_vpa, :string, :limit=> 1, default: 'N'  rescue nil
    add_column :partners, :merchant_id, :string, :limit => 30 rescue nil
  end
end
