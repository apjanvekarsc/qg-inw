require 'spec_helper'

describe PurposeCodeSearcher do
  context 'searcher' do
    it 'should return purpose_code' do
      purpose_code = Factory(:purpose_code, :approval_status => 'U')
      PurposeCodeSearcher.new({approval_status: 'U'}).paginate.should == [purpose_code]
      PurposeCodeSearcher.new({approval_status: 'A'}).paginate.should == []

      purpose_code = Factory(:purpose_code, :code => 'PC08', :approval_status =>'A')
      PurposeCodeSearcher.new({code: 'PC08'}).paginate.should == [purpose_code]
      PurposeCodeSearcher.new({code: 'PC01'}).paginate.should == []

      purpose_code = Factory(:purpose_code, :is_enabled => 'Y', code: 'PC09', :approval_status =>'A')
      PurposeCodeSearcher.new({is_enabled: 'Y', code: 'PC09'}).paginate.should == [purpose_code]
      PurposeCodeSearcher.new({is_enabled: 'N', code: 'PC09'}).paginate.should == []
      
    end
  end
end
