require 'spec_helper'

describe InwIdentity do
  context 'association' do
    it { should belong_to(:inward_remittance) }
  end

  context 'validation' do
    it { should validate_length_of(:id_type).is_at_most(30) }

    it "should validate the length of the id_type" do
      inw_identity = Factory(:inw_identity, :id_type => "Marraige Certificate")
      inw_identity.should be_valid
      inw_identity.errors_on(:id_type).should == []

      inw_identity = Factory.build(:inw_identity, :id_type => "Posted Mail with name of applicant")
      inw_identity.should_not be_valid
      inw_identity.errors_on(:id_type).should == ["is too long (maximum is 30 characters)"]
    end
  end

  context "full_name" do 
    it "should return remitter full name if the id_for is 'R'" do 
      identity = Factory(:inw_identity)
      identity.full_name.should == identity.inward_remittance.rmtr_full_name
    end

    it "should return beneficiary full name if the id_for is not 'R'" do 
      identity = Factory(:inw_identity)
      identity.full_name.should == identity.inward_remittance.bene_full_name
    end
  end
end