require 'spec_helper'

describe WhitelistedIdentity do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context 'association' do
    it { should have_many(:attachments)}
    it { should belong_to(:created_user)}
    it { should belong_to(:updated_user)}
    it { should belong_to(:inward_remittance)}
    it { should belong_to(:partner)}
    it { should have_one(:unapproved_record_entry) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end

  context 'validation' do
    [:partner, :id_for, :created_for_req_no, :created_by, :id_type, :id_number, :id_expiry_date, :full_name].each do |att|
      it { should validate_presence_of(att) }
    end

    it "should validate_unapproved_record" do 
      whitelisted_identity1 = Factory(:whitelisted_identity,:approval_status => 'A')
      whitelisted_identity2 = Factory(:whitelisted_identity, :approved_id => whitelisted_identity1.id)
      whitelisted_identity1.should_not be_valid
      whitelisted_identity1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end
  end
  
  context "fields format" do
    it "should allow valid format" do
      [:id_country].each do |att|
        should allow_value('IN').for(att)
        should allow_value('US').for(att)
      end
    end

    it "should not allow invalid format" do
      whitelisted_identity = Factory.build(:whitelisted_identity, :id_country => 'A', :id_type => "Aadhar1")
      whitelisted_identity.save.should be_false
      [:id_country].each do |att|
        whitelisted_identity.errors_on(att).should == ["Invalid format, expected format is : {[A-Z]{2}}"]
      end
    end
  end 
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      whitelisted_identity1 = Factory(:whitelisted_identity, :approval_status => 'A') 
      whitelisted_identity2 = Factory(:whitelisted_identity, :id_type => "Aadhar")
      WhitelistedIdentity.all.should == [whitelisted_identity1]
      whitelisted_identity2.approval_status = 'A'
      whitelisted_identity2.save
      WhitelistedIdentity.all.should == [whitelisted_identity1,whitelisted_identity2]
    end
  end    

  context "unapproved_records" do 
    it "oncreate: should create unapproved_record_entry if the approval_status is 'U'" do
      whitelisted_identity = Factory(:whitelisted_identity)
      whitelisted_identity.reload
      whitelisted_identity.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record_entry if the approval_status is 'A'" do
      whitelisted_identity = Factory(:whitelisted_identity, :approval_status => 'A')
      whitelisted_identity.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record_entry if approval_status did not change from U to A" do
      whitelisted_identity = Factory(:whitelisted_identity)
      whitelisted_identity.reload
      whitelisted_identity.unapproved_record_entry.should_not be_nil
      record = whitelisted_identity.unapproved_record_entry
      # we are editing the U record, before it is approved
      whitelisted_identity.id_type = 'Aadhar'
      whitelisted_identity.save
      whitelisted_identity.reload
      whitelisted_identity.unapproved_record_entry.should == record
    end
    
    it "onupdate: should remove unapproved_record_entry if the approval_status changed from 'U' to 'A' (approval)" do
      whitelisted_identity = Factory(:whitelisted_identity)
      whitelisted_identity.reload
      whitelisted_identity.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      whitelisted_identity.approval_status = 'A'
      whitelisted_identity.save
      whitelisted_identity.reload
      whitelisted_identity.unapproved_record_entry.should be_nil
    end
    
    it "ondestroy: should remove unapproved_record_entry if the record with approval_status 'U' was destroyed (approval) " do
      whitelisted_identity = Factory(:whitelisted_identity)
      whitelisted_identity.reload
      whitelisted_identity.unapproved_record_entry.should_not be_nil
      record = whitelisted_identity.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      whitelisted_identity.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      whitelisted_identity = Factory(:whitelisted_identity, :approval_status => 'U')
      whitelisted_identity.approve.save.should == true
      whitelisted_identity.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      whitelisted_identity = Factory(:whitelisted_identity, :approval_status => 'A')
      whitelisted_identity2 = Factory(:whitelisted_identity, :approval_status => 'U', :approved_id => whitelisted_identity.id, :approved_version => 6)
      whitelisted_identity2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      whitelisted_identity1 = Factory(:whitelisted_identity, :approval_status => 'A')
      whitelisted_identity2 = Factory(:whitelisted_identity, :approval_status => 'U')
      whitelisted_identity1.enable_approve_button?.should == false
      whitelisted_identity2.enable_approve_button?.should == true
    end
  end
end