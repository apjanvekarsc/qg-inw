require 'spec_helper'

describe PurposeCodeHelper do

  context 'disallowed_rem_and_bene_types_to_array'do
    it 'should be an array' do
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "I,C", :disallowed_bene_types => "I,C" )
      convert_options_to_array("I,C").should == ["I","C"]
      convert_options_to_array("I,C").should == ["I","C"]
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "I", :disallowed_bene_types => "C" )
      convert_options_to_array("I").should == ["I"]
      convert_options_to_array("C").should == ["C"]
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "I", :disallowed_bene_types => "" )
      convert_options_to_array("I").should == ["I"]
      convert_options_to_array("").should == []
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "", :disallowed_bene_types => "" )
      convert_options_to_array("").should == []
      convert_options_to_array("").should == []
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => nil, :disallowed_bene_types => nil)
      convert_options_to_array(nil).should == []
      convert_options_to_array(nil).should == []
    end
  end 
  
  context 'disallowed_rem_and_bene_types_values_on_show_page'do    
    it 'should show values on show page' do
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "I,C")
      disallowed_bene_and_rem_types_on_show_page("I,C").should == "Individual,Corporates"
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "I")
      disallowed_bene_and_rem_types_on_show_page("I").should == "Individual"
      purpose_code= Factory.build(:purpose_code, :disallowed_rem_types => "C")
      disallowed_bene_and_rem_types_on_show_page("C").should == "Corporates"
    end
  end
end