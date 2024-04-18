require 'spec_helper'

describe InwGuidelineHelper do
  context "find_inw_guidelines" do
    it "should find inw_guidelines" do
      inw_guideline = Factory(:inw_guideline, :code => 'FooBar', :approval_status => 'A')
      find_inw_guidelines({:code => 'FooBar'}).should == [inw_guideline]
      find_inw_guidelines({:code => 'BarFoo'}).should == []
    end
  end
end
