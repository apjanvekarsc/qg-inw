require 'spec_helper'

describe InwGuideline do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:unapproved_record_entry) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end
  
  context 'validation' do
    [:code, :allow_neft, :allow_imps, :allow_rtgs].each do |att|
      it { should validate_presence_of(att) }
    end


    it do 
      inw_guideline = Factory(:inw_guideline, code: '98123', :approval_status => 'A')
      should validate_uniqueness_of(:code).scoped_to(:approval_status)
    end
    
    it { should validate_numericality_of(:ytd_txn_cnt_bene) }
  end
  
  context "code format" do
    it "should allow valid format" do 
      [:code].each do |att|
        should allow_value('a12232424V').for(att)
        should allow_value('abcddfgdfg').for(att)
        should allow_value('1234545435').for(att)
        should allow_value('aBCDdfdsgs').for(att)
      end
    end

    it "should not allow invalid format" do 
      [:code].each do |att|
        should_not allow_value('ab*dsgdsgf').for(att)
        should_not allow_value('@acddsfdfd').for(att)
        should_not allow_value('134\ndsfdsg').for(att)
      end
    end
  end
  
  context "validate_disallowed_products" do 
    it "should validate keywords in disallowed products" do 
      inw_guideline = Factory.build(:inw_guideline, :disallowed_products => "1234 ese@sdgs")
      inw_guideline.should_not be_valid
      inw_guideline.errors_on("disallowed_products").should == ["is invalid"]
      inw_guideline = Factory.build(:inw_guideline, :disallowed_products => "1234 abcdef")
      inw_guideline.should_not be_valid
      inw_guideline.errors_on("disallowed_products").should == ["is invalid"]
      inw_guideline = Factory.build(:inw_guideline, :disallowed_products => "1234 1111")
      inw_guideline.should be_valid
      inw_guideline = Factory.build(:inw_guideline, :disallowed_products => "  ")
      inw_guideline.should be_valid
      inw_guideline.disallowed_products.should == ""
    end
  end
  
  context "set_txn_cnt" do
    it "should set ytd_txn_cnt_bene if it is nil" do
      inw_guideline = Factory(:inw_guideline, ytd_txn_cnt_bene: nil)
      inw_guideline.ytd_txn_cnt_bene.should == 0
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      inw_guideline1 = Factory(:inw_guideline, :approval_status => 'A') 
      inw_guideline2 = Factory(:inw_guideline, :code => '9008')
      inw_guidelines = InwGuideline.all
      InwGuideline.all.should == [inw_guideline1]
      inw_guideline2.approval_status = 'A'
      inw_guideline2.save
      InwGuideline.all.should == [inw_guideline1,inw_guideline2]
    end
  end

  context "unapproved_records" do 
    it "oncreate: should create unapproved_record_entry if the approval_status is 'U'" do
      inw_guideline = Factory(:inw_guideline)
      inw_guideline.reload
      inw_guideline.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record_entry if the approval_status is 'A'" do
      inw_guideline = Factory(:inw_guideline, :approval_status => 'A')
      inw_guideline.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record_entry if approval_status did not change from U to A" do
      inw_guideline = Factory(:inw_guideline)
      inw_guideline.reload
      inw_guideline.unapproved_record_entry.should_not be_nil
      record = inw_guideline.unapproved_record_entry
      # we are editing the U record, before it is approved
      inw_guideline.code = '12092'
      inw_guideline.save
      inw_guideline.reload
      inw_guideline.unapproved_record_entry.should == record
    end
    
    it "onupdate: should remove unapproved_record_entry if the approval_status changed from 'U' to 'A' (approval)" do
      inw_guideline = Factory(:inw_guideline)
      inw_guideline.reload
      inw_guideline.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      inw_guideline.approval_status = 'A'
      inw_guideline.save
      inw_guideline.reload
      inw_guideline.unapproved_record_entry.should be_nil
    end
    
    it "ondestroy: should remove unapproved_record_entry if the record with approval_status 'U' was destroyed (approval) " do
      inw_guideline = Factory(:inw_guideline)
      inw_guideline.reload
      inw_guideline.unapproved_record_entry.should_not be_nil
      record = inw_guideline.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      inw_guideline.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      inw_guideline = Factory(:inw_guideline, :approval_status => 'U')
      inw_guideline.approve.save.should == true
      inw_guideline.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      inw_guideline = Factory(:inw_guideline, :approval_status => 'A')
      inw_guideline1 = Factory(:inw_guideline, :approval_status => 'U', :approved_id => inw_guideline.id, :approved_version => 6)
      inw_guideline1.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      inw_guideline1 = Factory(:inw_guideline, :approval_status => 'A')
      inw_guideline2 = Factory(:inw_guideline, :approval_status => 'U')
      inw_guideline1.enable_approve_button?.should == false
      inw_guideline2.enable_approve_button?.should == true
    end
  end
  
end
