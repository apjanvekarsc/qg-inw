require 'spec_helper'

describe PartnerLcyRate do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should belong_to(:partner) }
    it { should have_one(:unapproved_record_entry ) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end

  context 'validation' do
    [:partner_code, :rate].each do |att|
      it { should validate_presence_of(att) }
    end

    [:rate].each do |att|
      it {should validate_numericality_of(att)}
    end

    it do
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'A')
      should validate_uniqueness_of(:partner_code).scoped_to(:approval_status)
    end

    it "should validate_unapproved_record" do
      partner_lcy_rate1 = Factory(:partner_lcy_rate,:approval_status => 'A')
      partner_lcy_rate2 = Factory(:partner_lcy_rate, :approved_id => partner_lcy_rate1.id)
      partner_lcy_rate1.should_not be_valid
      partner_lcy_rate1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end

    it 'should give error lcy_rate has more than two digits after decimal point' do
      partner_lcy_rate = Factory.build(:partner_lcy_rate, :approval_status => 'A', rate: 10.888)
      partner_lcy_rate.errors_on(:rate).first.should == "is invalid, only two digits are allowed after decimal point"
    end
    
    it 'should give error lcy_rate has value greater than 1 and needs_lcy_rate of guideline is N' do
      inw_guideline = Factory(:inw_guideline, needs_lcy_rate: 'N', approval_status: 'A')
      partner = Factory(:partner, guideline: inw_guideline, approval_status: 'A')
      partner.reload
      partner_lcy_rate = partner.partner_lcy_rate
      partner_lcy_rate.rate = 2
      partner_lcy_rate.save.should == false
      partner_lcy_rate.errors_on(:rate).first.should == "can't be greater than 1 because needs_lcy_rate is N for the guideline"
    end

    context "code format" do
      it "should allow valid format" do 
        [:partner_code].each do |att|
          should allow_value('a12232424V').for(att)
          should allow_value('abcddfgdfg').for(att)
          should allow_value('1234545435').for(att)
          should allow_value('aBCDdfdsgs').for(att)
        end
      end

      it "should not allow invalid format" do 
        [:partner_code].each do |att|
          should_not allow_value('ab*dsgdsgf').for(att)
          should_not allow_value('@acddsfdfd').for(att)
          should_not allow_value('134\ndsfdsg').for(att)
        end
      end
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      partner_lcy_rate1 = Factory(:partner_lcy_rate, :approval_status => 'A') 
      partner_lcy_rate2 = Factory(:partner_lcy_rate)
      PartnerLcyRate.all.should == [partner_lcy_rate1]
      partner_lcy_rate2.approval_status = 'A'
      partner_lcy_rate2.save
      PartnerLcyRate.all.should == [partner_lcy_rate1,partner_lcy_rate2]
    end
  end    

  context "unapproved_records" do 
    it "oncreate: should create unapproved_record_entry if the approval_status is 'U'" do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      partner_lcy_rate.reload
      partner_lcy_rate.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record_entry if the approval_status is 'A'" do
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'A')
      partner_lcy_rate.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record_entry if approval_status did not change from U to A" do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      partner_lcy_rate.reload
      partner_lcy_rate.unapproved_record_entry.should_not be_nil
      record = partner_lcy_rate.unapproved_record_entry
      # we are editing the U record, before it is approved
      partner_lcy_rate.rate = 'Fooo'
      partner_lcy_rate.save
      partner_lcy_rate.reload
      partner_lcy_rate.unapproved_record_entry.should == record
    end
    
    it "onupdate: should remove unapproved_record_entry if the approval_status changed from 'U' to 'A' (approval)" do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      partner_lcy_rate.reload
      partner_lcy_rate.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      partner_lcy_rate.approval_status = 'A'
      partner_lcy_rate.save
      partner_lcy_rate.reload
      partner_lcy_rate.unapproved_record_entry.should be_nil
    end
    
    it "ondestroy: should remove unapproved_record_entry if the record with approval_status 'U' was destroyed (approval) " do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      partner_lcy_rate.reload
      partner_lcy_rate.unapproved_record_entry.should_not be_nil
      record = partner_lcy_rate.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      partner_lcy_rate.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'U')
      partner_lcy_rate.approve.save.should == true
      partner_lcy_rate.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'A')
      partner_lcy_rate2 = Factory(:partner_lcy_rate, :approval_status => 'U', :approved_id => partner_lcy_rate.id, :approved_version => 6)
      partner_lcy_rate2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      partner_lcy_rate1 = Factory(:partner_lcy_rate, :approval_status => 'A')
      partner_lcy_rate2 = Factory(:partner_lcy_rate, :approval_status => 'U')
      partner_lcy_rate1.enable_approve_button?.should == false
      partner_lcy_rate2.enable_approve_button?.should == true
    end
  end
end