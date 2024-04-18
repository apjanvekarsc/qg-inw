class AddSenderRcToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :sender_rc, :string,:limit => 20, :null => false rescue nil
  end
end
