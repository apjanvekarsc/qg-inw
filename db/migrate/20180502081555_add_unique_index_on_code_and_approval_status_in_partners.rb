class AddUniqueIndexOnCodeAndApprovalStatusInPartners < ActiveRecord::Migration
  def change
    add_index :partners, [:code, :approval_status], :unique => true, :name => "partners_01"
  end
end
