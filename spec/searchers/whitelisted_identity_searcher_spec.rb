require 'spec_helper'

describe WhitelistedIdentitySearcher do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context 'searcher' do
    it 'should return whitelisted identities' do
      partner = Factory(:partner,:enabled => 'Y', will_send_id: 'N', :approval_status => 'A', :code => 'a123')
      inward_remittance = Factory(:inward_remittance, partner_code: partner.code, rmtr_full_name: 'MyString', rmtr_code: 'MyString')
      identity = Factory(:whitelisted_identity, :partner_id => partner.id, created_for_req_no: inward_remittance.req_no, full_name: 'MyString', rmtr_code: 'MyString', :approval_status => 'A')
      searcher = WhitelistedIdentitySearcher.new({:rmtr_code => '1234'})
      searcher.errors_on(:base).should_not be_nil
      searcher.errors_on(:base).should == ['Partner code is mandatory when using advanced search']
      searcher.paginate.should == []
      WhitelistedIdentitySearcher.new({:partner_code => 'a123'}).paginate.should == [identity]
      WhitelistedIdentitySearcher.new({:partner_code => 'A123'}).paginate.should == []
      WhitelistedIdentitySearcher.new({:partner_code => 'ab123'}).paginate.should == []

      inward_remittance = Factory(:inward_remittance, partner_code: partner.code, rmtr_full_name: 'foobar', rmtr_code: 'foobar')
      identity = Factory(:whitelisted_identity, :partner_id => partner.id, created_for_req_no: inward_remittance.req_no, :full_name => 'foobar', :approval_status => 'A', :id_type => 'driving license', rmtr_code: 'foobar')
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :name => 'foobar'}).paginate.should == [identity]
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :name => 'foo'}).paginate.should == []
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :name => 'bar'}).paginate.should == []

      inward_remittance = Factory(:inward_remittance, partner_code: partner.code, rmtr_full_name: 'foobar2', rmtr_code: 'foobar2')
      identity = Factory(:whitelisted_identity, :partner_id => partner.id, created_for_req_no: inward_remittance.req_no, :full_name => 'foobar2', :approval_status => 'A', :id_type => 'passport', rmtr_code: 'foobar2')
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :rmtr_code => 'foobar2'}).paginate.should == [identity]
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :rmtr_code => 'foo'}).paginate.should == []
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :rmtr_code => 'bar'}).paginate.should == []

      inward_remittance = Factory(:inward_remittance, partner_code: partner.code, bene_full_name: 'MyString', bene_account_no: '987654320987')
      identity = Factory(:whitelisted_identity, :partner_id => partner.id, created_for_req_no: inward_remittance.req_no, :approval_status => 'A', :id_type => 'pan', full_name: 'MyString', id_for: 'B')
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :bene_account_no => '987654320987'}).paginate.should == [identity]
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :bene_account_no => 'foo'}).paginate.should == []
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :bene_account_no => 'bar'}).paginate.should == []

      inward_remittance = Factory(:inward_remittance, partner_code: partner.code, bene_full_name: 'MyString', bene_account_ifsc: 'ABCD0123456')
      identity = Factory(:whitelisted_identity, :partner_id => partner.id, created_for_req_no: inward_remittance.req_no, :approval_status => 'A', :id_type => 'aadhar', full_name: 'MyString', id_for: 'B')
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :bene_account_ifsc => 'ABCD0123456'}).paginate.should == [identity]
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :bene_account_ifsc => 'ABCD'}).paginate.should == []
      WhitelistedIdentitySearcher.new({:partner_code => inward_remittance.partner_code, :bene_account_ifsc => 'abc'}).paginate.should == []   
      
      partner = Factory(:partner,:enabled => 'Y', will_send_id: 'Y', :approval_status => 'A', :code => 'a222')
      inward_remittance = Factory(:inward_remittance, partner_code: partner.code, rmtr_full_name: 'MyString', rmtr_code: 'MyString')
      identity = Factory(:whitelisted_identity, :partner_id => partner.id, created_for_req_no: inward_remittance.req_no, full_name: 'MyString', rmtr_code: 'MyString1', :approval_status => 'A')
      searcher = WhitelistedIdentitySearcher.new({:partner_code => 'a222', :rmtr_code => 'MyString1'})
      searcher.errors_on(:base).should_not be_nil
      searcher.errors_on(:base).should == ['Search is not allowed on ID Detail (i.e., RemitterCode, Beneficiary Account No and Beneficiary IFSC) for this Partner since Will Send ID is not N']
      searcher.paginate.should == []
    end
  end
end
