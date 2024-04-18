require 'spec_helper'

describe PartnerLcyRateSearcher do
  context 'searcher' do
    it 'should return partner_lcy_rate' do
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'U')
      PartnerLcyRateSearcher.new({approval_status: 'U'}).paginate.should == [partner_lcy_rate]
      PartnerLcyRateSearcher.new({approval_status: 'A'}).paginate.should == []
      
      partner_lcy_rate = Factory(:partner_lcy_rate, :partner_code => 'STRING1', approval_status: 'A')
      PartnerLcyRateSearcher.new({partner_code: 'STRING1', approval_status: 'A'}).paginate.should == [partner_lcy_rate]
      PartnerLcyRateSearcher.new({partner_code: 'STRING2', approval_status: 'A'}).paginate.should == []

    end
  end
end
