require 'spec_helper'

describe PartnerSearcher do
  context 'searcher' do
    it 'should return partner' do
      partner = Factory(:partner, :approval_status => 'U')
      PartnerSearcher.new({approval_status: 'U'}).paginate.should == [partner]
      PartnerSearcher.new({approval_status: 'A'}).paginate.should == []

      partner = Factory(:partner, :enabled => 'Y', :approval_status => 'A')
      PartnerSearcher.new({enabled: 'Y'}).paginate.should == [partner]
      PartnerSearcher.new({enabled: 'N'}).paginate.should == []
      
      partner = Factory(:partner, :code => 'STRING1', :approval_status => 'A')
      PartnerSearcher.new({code: 'STRING1'}).paginate.should == [partner]
      PartnerSearcher.new({code: 'STRING2'}).paginate.should == []

      partner = Factory(:partner, :account_no => '1111111111', :approval_status => 'A')
      PartnerSearcher.new({account_no: '1111111111'}).paginate.should == [partner]
      PartnerSearcher.new({account_no: '1111111119'}).paginate.should == []

      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      partner = Factory(:partner, customer_id: '2345', :allow_neft => 'Y', :approval_status => 'A',  :code => 'STRING3')
      PartnerSearcher.new({allow_neft: 'Y',  code: 'STRING3'}).paginate.should == [partner]
      PartnerSearcher.new({allow_neft: 'N',  code: 'STRING3'}).paginate.should == []
      
      partner = Factory(:partner, :allow_rtgs  => 'Y', :approval_status => 'A', :code => 'STRING4')
      PartnerSearcher.new({rtgs_allow: 'Y', code:'STRING4'}).paginate.should == [partner]
      PartnerSearcher.new({rtgs_allow: 'N', code:'STRING4'}).paginate.should == []

      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890', mmid: '1234123')
      partner = Factory(:partner, customer_id: '2345', allow_imps: 'Y', :approval_status => 'A', :code => 'STRING5', account_no: '1234567890', mmid: '1234123', mobile_no: '2222222222')
      PartnerSearcher.new({imps_allow: 'Y', code:'STRING5'}).paginate.should == [partner]
      PartnerSearcher.new({imps_allow: 'N', code:'STRING5'}).paginate.should == []
    end
  end
end
