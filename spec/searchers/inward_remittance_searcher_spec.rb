require 'spec_helper'

describe InwardRemittanceSearcher do
  context 'searcher' do
    it 'should return inward remittances' do
      inward_remittance = Factory(:inward_remittance,:req_no => 'Z123', :attempt_no => 0)
      inward_remittance2 = Factory(:inward_remittance,:req_no => 'Z123', :attempt_no => 1)      
      searcher = InwardRemittanceSearcher.new({:status_code => 'IN_PROCESS'})
      searcher.errors_on(:partner_id).should_not be_nil
      searcher.errors_on(:partner_id).should == ['Partner Code is mandatory']
      searcher.paginate.should == []

      inward_remittance = Factory(:inward_remittance,:status_code => 'IN_PROCESS')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :status_code => 'IN_PROCESS'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :status_code => 'COMPLETED'}).paginate.should == []

      inward_remittance = Factory(:inward_remittance,:notify_status => 'IN_PROCESS')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :notify_status => 'IN_PROCESS'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :notify_status => 'COMPLETED'}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance,:req_no => 'R1234')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :request_no => 'R1234'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :request_no => 'r1234'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :request_no => 'r12'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :request_no => 'R12'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code, :request_no => '4321R'}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance,:partner_code => 'PARTNER1')
      InwardRemittanceSearcher.new({:partner_id => 'PARTNER1'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => 'PART'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => 'part'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => 'PARTNER2'}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance,:bank_ref => '123444')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:bank_ref => '123444'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:bank_ref => '123443'}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance, :rmtr_full_name => "AABBCC DDEE")
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:rmtr_full_name => "AABBCC DDEE"}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:rmtr_full_name => "AACCC DDEE"}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance,:req_transfer_type => 'IMPS')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:req_transfer_type => 'IMPS'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:req_transfer_type => 'NEFT'}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance,:req_transfer_type => 'FT')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:req_transfer_type => 'FT'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:req_transfer_type => 'NEFT'}).paginate.should == []
  
      inward_remittance = Factory(:inward_remittance,:transfer_type => 'NEFT')
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:transfer_type => 'NEFT'}).paginate.should == [inward_remittance]
      InwardRemittanceSearcher.new({:partner_id => inward_remittance.partner_code,:transfer_type => 'IMPS'}).paginate.should == []
  
      inward_remittance = [Factory(:inward_remittance, :transfer_amount => '10000', :partner_code => '123')]
      inward_remittance << Factory(:inward_remittance, :transfer_amount => '9000', :partner_code => '123')
      inward_remittance << Factory(:inward_remittance, :transfer_amount => '8000', :partner_code => '123')
      InwardRemittanceSearcher.new({:partner_id => '123',:from_transfer_amount => '8000', :to_transfer_amount => '10000'}).paginate.should == inward_remittance.reverse
      InwardRemittanceSearcher.new({:partner_id => '123',:from_transfer_amount => '10000', :to_transfer_amount => '12000'}).paginate.should == [inward_remittance[0]]
  
      inward_remittance = [Factory(:inward_remittance, :req_timestamp => '2015-04-25', :partner_code => '123')]
      inward_remittance << Factory(:inward_remittance, :req_timestamp => '2015-04-26', :partner_code => '123')
      inward_remittance << Factory(:inward_remittance, :req_timestamp => '2015-04-27', :partner_code => '123')
      InwardRemittanceSearcher.new({:partner_id => '123',:from_req_timestamp => '2015-04-25', :to_req_timestamp => '2015-04-27'}).paginate.should == inward_remittance.reverse
      InwardRemittanceSearcher.new({:partner_id => '123',:from_req_timestamp => '2015-04-28', :to_req_timestamp => '2015-04-30'}).paginate.should == []
    end
  end
end
