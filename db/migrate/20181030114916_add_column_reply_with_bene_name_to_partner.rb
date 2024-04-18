class AddColumnReplyWithBeneNameToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :reply_with_bene_name, :string, :limit=> 1, :default => 'N', :comment => "the flag which indicates whether the bene name returned by the bene bank should be returned in the transferResponse or not"
  end
end
