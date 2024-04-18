require 'spec_helper'

describe InwardRemittance do
  context 'association' do
    it { should have_one(:partner) }
    it { should have_one(:purpose) }
    it { should have_many(:remitter_identities) }
    it { should have_many(:beneficiary_identities) }
  end

  context 'validation' do
    [:req_no, :req_version, :req_timestamp, :partner_code, :rmtr_identity_count, :bene_identity_count, :attempt_no].each do |att|
      it { should validate_presence_of(att) }
    end
  end

  context "remitter_address" do 
    it "should return remitter_address" do 
      inward_remittance = Factory(:inward_remittance, :rmtr_address1 => 'addr1', :rmtr_address2 => 'addr2', :rmtr_address3 => 'addr3')
      inward_remittance.remitter_address.should == "addr1 addr2 addr3"
    end
  end

  context "beneficiary_address" do 
    it "should return beneficiary_address" do 
      inward_remittance = Factory(:inward_remittance, :bene_address1 => 'addr1', :bene_address2 => 'addr2', :bene_address3 => 'addr3')
      inward_remittance.beneficiary_address.should == "addr1 addr2 addr3"
    end
  end
  
  context "reply_time" do 
    it "should return reply time" do 
      inward_remittance = Factory(:inward_remittance, :rep_timestamp => '2015-04-20 20:12:44', :req_timestamp => '2015-04-20 15:12:44')
      inward_remittance.reply_time.should == 300
    end
  end
  
  context "self_transfer?" do 
    it "should return is_self_transfer?" do 
      inward_remittance = Factory.build(:inward_remittance, :is_self_transfer => 'Y')
      inward_remittance.self_transfer?.should == true
      inward_remittance = Factory.build(:inward_remittance, :is_self_transfer => 'N')
      inward_remittance.self_transfer?.should == false
    end
  end
end
