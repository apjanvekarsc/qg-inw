require 'spec_helper'

describe InwardRemittanceHelper do
  context "find_logs" do
    it "should return the logs" do
      transaction = Factory(:inward_remittance)
      log =  Factory(:inw_audit_step, :inw_auditable_type => 'InwardRemittance', :inw_auditable_id => transaction.id, :step_name => 'NOTIFY')
      find_logs({:step_name => 'NOTIFY'},transaction).should == transaction.audit_steps
      find_logs({:step_name => 'RETURN'},transaction).should == []
    end
  end
end