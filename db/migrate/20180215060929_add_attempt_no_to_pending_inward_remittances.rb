class AddAttemptNoToPendingInwardRemittances < ActiveRecord::Migration
  def change
    add_column :pending_inward_remittances, :attempt_no, :integer, comment: 'the attempt number of the requery'     
  end
end
