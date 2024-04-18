require 'spec_helper'

describe InwAuditLog do
  context 'association' do
    it { should belong_to(:inward_remittance) }
  end

  context "request_bit" do
    it "should return request_bitstream in xml format" do 
      inw = Factory.build(:inw_audit_log, :request_bitstream => "<a><b>c</b></a>")
      inw.request_bit.should == "<a>\n <b>\n  c\n </b>\n</a>"
      inw = Factory.build(:inw_audit_log, :request_bitstream => "<a><b>")
      inw.request_bit.should == "Error in conversion"
    end
  end

  context "reply_bit" do
    it "should return reply_bitstream in xml format" do 
      inw = Factory(:inw_audit_log, :reply_bitstream => "<a><b>c</b></a>")
      inw.reply_bit.should == "<a>\n <b>\n  c\n </b>\n</a>"
      inw = Factory.build(:inw_audit_log, :reply_bitstream => "<a><b>")
      inw.reply_bit.should == "Error in conversion"
    end
  end

  context "convert_to_xml" do
    it "should convert the value to xml format" do 
      inw = Factory(:inw_audit_log, :reply_bitstream => "<a><b>c</b></a>")
      inw.convert_to_xml("<a><b>c</b></a>").should == "<a>\n <b>\n  c\n </b>\n</a>"
      inw.convert_to_xml("<a><b>").should == "Error in conversion"
    end
  end
end
