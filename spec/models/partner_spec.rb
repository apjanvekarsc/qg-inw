require 'spec_helper'

describe Partner do
  include HelperMethods

  before(:each) do
    mock_ldap
  end
  
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:unapproved_record_entry) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end

  context 'validation' do
    [:code, :enabled, :name, :account_no, :txn_hold_period_days,
    :remitter_email_allowed, :remitter_sms_allowed, :allow_imps, 
    :allow_neft, :allow_rtgs, :country, :account_ifsc, :identity_user_id, 
    :add_req_ref_in_rep, :add_transfer_amt_in_rep, :notify_on_status_change].each do |att|
      it { should validate_presence_of(att) }
    end

    [:account_no, :low_balance_alert_at, :mmid, :mobile_no, :txn_hold_period_days].each do |att|
      it {should validate_numericality_of(att)}
    end

    it do
      partner = Factory(:partner, :account_no => '1234567890123456', :account_ifsc => 'abcd0123456', :approval_status => 'A')
      should validate_uniqueness_of(:code).scoped_to(:approval_status)
    end

    it 'should check presence of app_code if notify on status change is Y' do
      partner = Factory.build(:partner, :account_no => '1234567890123456', :account_ifsc => 'abcd0123456', :approval_status => 'A', :notify_on_status_change => 'Y')
      partner.errors_on(:app_code).first.should == "Mandatory if notify on status change is checked"
    end

    it 'should check format and length of app_code if notify on status change is Y' do
      partner = Factory.build(:partner, :account_no => '1234567890123456', :account_ifsc => 'abcd0123456', :approval_status => 'A', :notify_on_status_change => 'Y', :app_code => '1234#')
      partner.errors_on(:app_code).first.should == "Invalid format, expected format is : {[a-z|A-Z|0-9]}"
    end
    
    it 'should check format and length of app_code if notify on status change is Y' do
      partner = Factory.build(:partner, :account_no => '1234567890123456', :account_ifsc => 'abcd0123456', :approval_status => 'A', :notify_on_status_change => 'Y', :app_code => '1234567891011121343584354')
      partner.errors_on(:app_code).first.should == "is too long (maximum is 20 characters)"
    end

    it 'should check format and length of app_code if notify on status change is Y' do
      partner = Factory.build(:partner, :account_no => '1234567890123456', :account_ifsc => 'abcd0123456', :approval_status => 'A', :notify_on_status_change => 'Y', :app_code => '1234')
      partner.errors_on(:app_code).first.should == "is too short (minimum is 5 characters)"
    end

    it "should validate_unapproved_record" do 
      partner1 = Factory(:partner,:approval_status => 'A')
      partner2 = Factory(:partner, :approved_id => partner1.id)
      partner1.should_not be_valid
      partner1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end
    
    it 'should give error if will_whitelist = N and hold_for_whitelisting = Y' do
      partner = Factory.build(:partner, :approval_status => 'A', :will_whitelist => 'N', :hold_for_whitelisting => 'Y')
      partner.errors_on(:hold_for_whitelisting).first.should == "Allowed only when service is INW2 and Will Whitelist is true"
    end
    
    it 'should give error if hold_for_whitelisting = N and txn_hold_period_days != 0' do
      partner = Factory.build(:partner, :approval_status => 'A', :txn_hold_period_days => 8, :hold_for_whitelisting => 'N')
      partner.errors_on(:txn_hold_period_days).first.should == "Allowed only when Hold for Whitelisting is true"
    end
    
    it 'should give error if service_name = INW and hold_for_whitelisting = Y' do
      partner = Factory.build(:partner, :approval_status => 'A', :service_name => 'INW', :hold_for_whitelisting => 'Y')
      partner.errors_on(:hold_for_whitelisting).first.should == "Allowed only when service is INW2 and Will Whitelist is true"
    end
    
    it 'should give error if will_send_id = Y and will_whitelist = N' do
      partner = Factory.build(:partner, :approval_status => 'A', :will_send_id => 'Y', :will_whitelist => 'N')
      partner.errors_on(:will_send_id).first.should == "Allowed only when Will Whitelist is true"
    end
    
    it 'should give error if any transfer_type is not allowed in the guideline and the same is allowed for the partner' do
      guideline1 = Factory(:inw_guideline, approval_status: 'A', allow_neft: 'N')
      partner = Factory.build(:partner, :approval_status => 'A', allow_neft: 'Y', guideline_id: guideline1.id)
      partner.errors_on(:allow_neft).first.should == "Allowed only if the chosen guideline supports NEFT"
      
      guideline2 = Factory(:inw_guideline, approval_status: 'A', allow_rtgs: 'N')
      partner = Factory.build(:partner, :approval_status => 'A', allow_rtgs: 'Y', guideline_id: guideline2.id)
      partner.errors_on(:allow_rtgs).first.should == "Allowed only if the chosen guideline supports RTGS"
      
      guideline3 = Factory(:inw_guideline, approval_status: 'A', allow_imps: 'N')
      partner = Factory.build(:partner, :approval_status => 'A', allow_imps: 'Y', guideline_id: guideline3.id)
      partner.errors_on(:allow_imps).first.should == "Allowed only if the chosen guideline supports IMPS"
    end
    
    it 'should give error if service_name = INW2 and remitter_sms_allowed = Y' do
      partner = Factory.build(:partner, :approval_status => 'A', :service_name => 'INW2', :remitter_sms_allowed => 'Y')
      partner.errors_on(:remitter_sms_allowed).first.should == "Allowed only when service is INW"
    end
    
    it 'should give error if service_name = INW2 and remitter_email_allowed = Y' do
      partner = Factory.build(:partner, :approval_status => 'A', :service_name => 'INW2', :remitter_email_allowed => 'Y')
      partner.errors_on(:remitter_email_allowed).first.should == "Allowed only when service is INW"
    end

    it { should validate_length_of(:account_no).is_at_least(10) }
    it { should validate_length_of(:account_no).is_at_most(16) }
    it { should validate_length_of(:mobile_no).is_at_least(10) }
    it { should validate_length_of(:mobile_no).is_at_most(10) }
    it { should validate_length_of(:mmid).is_at_least(7) }
    it { should validate_length_of(:mmid).is_at_most(7) }
    it { should validate_length_of(:customer_id).is_at_most(15) }
    it { should validate_length_of(:add_req_ref_in_rep).is_at_least(1).is_at_most(1) }
    it { should validate_length_of(:add_transfer_amt_in_rep).is_at_least(1).is_at_most(1) }

    context "txn_hold_period_days" do 
      it "should accept value 0 to 15" do
        should allow_value(0).for(:txn_hold_period_days)
      end

      it "should not accept value other than 0 to 15" do
        should_not allow_value(-1).for(:txn_hold_period_days)
        should_not allow_value(16).for(:txn_hold_period_days)
      end
    end

    context "low_balance_alert_at" do 
      it "should accept following values" do
        should allow_value(0).for(:low_balance_alert_at)
        should allow_value('9e20'.to_f).for(:low_balance_alert_at)
      end

      it "should not accept following values" do
        should_not allow_value(-1).for(:low_balance_alert_at)
        should_not allow_value('9e21'.to_f).for(:low_balance_alert_at)
      end
    end

    context "code format" do
      it "should allow valid format" do 
        [:code,:name].each do |att|
          should allow_value('a12232424V').for(att)
          should allow_value('abcddfgdfg').for(att)
          should allow_value('1234545435').for(att)
          should allow_value('aBCDdfdsgs').for(att)
        end
      end

      it "should not allow invalid format" do 
        [:code,:name].each do |att|
          should_not allow_value('ab*dsgdsgf').for(att)
          should_not allow_value('@acddsfdfd').for(att)
          should_not allow_value('134\ndsfdsg').for(att)
        end
      end
    end
  
    context 'account_ifsc' do
      it "should allow only alpha numeric characters" do 
        partner = Factory.build(:partner, :account_ifsc => 'abcd0123456', :account_no => '1234567890123456')
        partner.should be_valid
        partner.errors_on(:account_ifsc).should == []
        partner = Factory.build(:partner, :account_ifsc => 'abcd01234bh', :account_no => '1234567890123456')
        partner.should be_valid
        partner.errors_on(:account_ifsc).should == []
        partner = Factory.build(:partner, :account_ifsc => 'abcd11234bh', :account_no => '1234567890123456')
        partner.should_not be_valid
        partner.errors_on(:account_ifsc).should == ["invalid format - expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}"]
        partner = Factory.build(:partner, :account_ifsc => 'abcdef', :account_no => '1234567890123456')
        partner.should_not be_valid
        partner.errors_on(:account_ifsc).should == ["invalid format - expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}"]
        partner = Factory.build(:partner, :account_ifsc => '123456', :account_no => '1234567890123456')
        partner.should_not be_valid
        partner.errors_on(:account_ifsc).should == ["invalid format - expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}"]
        partner = Factory.build(:partner, :account_ifsc => '123 456', :account_no => '1234567890123456')
        partner.should_not be_valid
        partner.errors_on(:account_ifsc).should == ["invalid format - expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}"]
      end
    end

    context "imps_and_mmid" do 
      it "should validate if mmid if imps is true" do 
        partner = Factory.build(:partner, :mmid => nil, :allow_imps => 'Y')
        partner.should_not be_valid
        partner.errors_on("mmid").should == ["MMID Mandatory for IMPS"]
      end

      it "should validate if mobile_no if imps is true" do 
        partner = Factory.build(:partner, :mobile_no => nil, :allow_imps => 'Y')
        partner.should_not be_valid
        partner.errors_on("mobile_no").should == ["Mobile No Mandatory for IMPS"]
      end
    end

    context "check_email_addresses" do 
      it "should validate email address" do 
        partner = Factory.build(:partner, :tech_email_id => "1234;esesdgs", :ops_email_id => "1234;esesdgs")
        partner.should_not be_valid
        partner.errors_on("tech_email_id").should == ["is invalid"]
        partner.errors_on("ops_email_id").should == ["is invalid"]
        partner = Factory.build(:partner, :tech_email_id => "foo@ruby.com", :ops_email_id => "foo@ruby.com;bar@ruby.com")
        partner.should be_valid
      end
    end

    context "country_name" do 
      it "should return full name for the country code" do 
        partner = Factory.build(:partner, :country => 'US')
        partner.country_name.should == 'United States'
        partner = Factory.build(:partner, :country => nil)
        partner.country_name.should == nil
      end
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      partner1 = Factory(:partner, :approval_status => 'A') 
      partner2 = Factory(:partner)
      Partner.all.should == [partner1]
      partner2.approval_status = 'A'
      partner2.save
      Partner.all.should == [partner1,partner2]
    end
  end    

  context "unapproved_records" do 
    it "oncreate: should create unapproved_record_entry if the approval_status is 'U'" do
      partner = Factory(:partner)
      partner.reload
      partner.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record_entry if the approval_status is 'A'" do
      partner = Factory(:partner, :approval_status => 'A')
      partner.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record_entry if approval_status did not change from U to A" do
      partner = Factory(:partner)
      partner.reload
      partner.unapproved_record_entry.should_not be_nil
      record = partner.unapproved_record_entry
      # we are editing the U record, before it is approved
      partner.name = 'Fooo'
      partner.save
      partner.reload
      partner.unapproved_record_entry.should == record
    end
    
    it "onupdate: should remove unapproved_record_entry if the approval_status changed from 'U' to 'A' (approval)" do
      partner = Factory(:partner)
      partner.reload
      partner.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      partner.approval_status = 'A'
      partner.save
      partner.reload
      partner.unapproved_record_entry.should be_nil
    end
    
    it "ondestroy: should remove unapproved_record_entry if the record with approval_status 'U' was destroyed (approval) " do
      partner = Factory(:partner)
      partner.reload
      partner.unapproved_record_entry.should_not be_nil
      record = partner.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      partner.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      partner = Factory(:partner, :approval_status => 'U')
      partner.approve.save.should == true
      partner.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      partner = Factory(:partner, :approval_status => 'A')
      partner2 = Factory(:partner, :approval_status => 'U', :approved_id => partner.id, :approved_version => 6)
      partner2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      partner1 = Factory(:partner, :approval_status => 'A')
      partner2 = Factory(:partner, :approval_status => 'U')
      partner1.enable_approve_button?.should == false
      partner2.enable_approve_button?.should == true
    end
  end
  
  context "options_for_auto_match_rule" do
    it "should return options_for_auto_match_rule" do
      Partner.options_for_auto_match_rule.should == [['None','N'],['Any','A']]
    end
  end

  context 'create_lcy_rate' do 
    it "should create partner_lcy_rate record" do
      partner = Factory(:partner, :guideline => Factory(:inw_guideline, :needs_lcy_rate => 'Y'))
      partner.reload
      partner.partner_lcy_rate.should_not be_nil
      lcy_rate = partner.partner_lcy_rate
      lcy_rate.partner_code.should == partner.code
      lcy_rate.rate.should == 1
    end
  end
  
  # context "presence_of_iam_cust_user" do
  #   it "should validate existence of iam_cust_user" do
  #     partner = Factory.build(:partner, identity_user_id: '1234')
  #     partner.errors_on(:identity_user_id).should == ['IAM Customer User does not exist for this username']
  #
  #     iam_cust_user = Factory(:iam_cust_user, username: '1234', approval_status: 'A')
  #     partner.errors_on(:identity_user_id).should == []
  #   end
  # end
  
  context "should_allow_neft?" do
    it "should allow neft for the partner when the customer setup is complete in FCR" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      partner = Factory.build(:partner, customer_id: '2345', allow_neft: 'Y', allow_imps: 'N', account_no: '1234567890')
      partner.errors_on(:customer_id).should == []
    end

    it "should raise error when the mobile no. and email are not present in the customer setup in FCR" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: nil)
      partner = Factory.build(:partner, customer_id: '2345', allow_neft: 'Y', allow_imps: 'N', account_no: '1234567890')
      partner.errors_on(:allow_neft).should == ["NEFT is not allowed for 2345 as the data setup in FCR is invalid"]
    end

    it "should raise error when there is no corresponding record in FCR" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      partner = Factory.build(:partner, customer_id: '234', allow_neft: 'Y', allow_imps: 'N', account_no: '0987654321')
      partner.errors_on(:customer_id).should == ["no record found in FCR for 234"]
    end
  end

  context "should_allow_imps?" do
    it "should allow imps for the partner when the customer setup is complete in FCR and ATOM" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890')
      partner = Factory.build(:partner, customer_id: '2345', allow_neft: 'N', allow_imps: 'Y', account_no: '1234567890')
      partner.errors_on(:customer_id).should == []
    end

    it "should raise error when there is no corresponding record in ATOM" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890', mmid: '1231234')
      partner = Factory.build(:partner, customer_id: '234', allow_neft: 'N', allow_imps: 'Y', account_no: '0987654321', mmid: '1231234', mobile_no: '9999999911')
      partner.errors_on(:base).should == ["no record found in ATOM for the combination of Account No: 0987654321, MMID: 1231234 & Mobile No: 9999999911"]
      
      partner = Factory.build(:partner, customer_id: '2345', allow_neft: 'N', allow_imps: 'Y', account_no: '0987654321', mmid: '1231200', mobile_no: '2222222222')
      partner.errors_on(:base).should == ["no record found in ATOM for the combination of Account No: 0987654321, MMID: 1231200 & Mobile No: 2222222222"]
      
      partner = Factory.build(:partner, customer_id: '2345', allow_neft: 'N', allow_imps: 'Y', account_no: '1234567890', mmid: '1231234', mobile_no: '2222222222')
      partner.errors_on(:base).should == []
    end

    it "should raise error when the mobile no.s in FCR and ATOM do not match for the customer" do
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890', mmid: '12341234')
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '9999000099', ref_cust_email: 'aaa@gmail.com')
      partner = Factory.build(:partner, customer_id: '2345', allow_neft: 'N', allow_imps: 'Y', account_no: '1234567890', mmid: '12341234', mobile_no: '2222222222')
      partner.errors_on(:account_no).should == ["IMPS is not allowed for 1234567890 as the data setup in ATOM is invalid"]
    end
  end
  
  context "auto_resch_and_service_name" do
    it "should raise error when service_name is 'INW' and auto_reschdl_to_next_wrk_day is 'Y'" do      
      partner = Factory.build(:partner, service_name: 'INW', auto_reschdl_to_next_wrk_day: 'Y')
      partner.errors_on(:auto_reschdl_to_next_wrk_day).should == ['Should not be checked when Service Name is INW']
    end
    
    it "should not raise error when service_name is 'INW' and auto_reschdl_to_next_wrk_day is 'N'" do      
      partner = Factory.build(:partner, service_name: 'INW', auto_reschdl_to_next_wrk_day: 'N')
      partner.errors_on(:auto_reschdl_to_next_wrk_day).should == []
    end
  end
  
end