require "rexml/document"

class InwAuditLog < ApplicationRecord
  # attr_accessible :inward_remittance_id, :reply_bitstream, :request_bitstream

  belongs_to :inward_remittance

  def request_bit
    convert_to_xml(request_bitstream)
  end

  def reply_bit
    convert_to_xml(reply_bitstream)
  end

  def convert_to_xml(value)
    begin
      doc = REXML::Document.new value 
      out = ""
      doc.write(out, 1)
      out
    rescue Exception => e
      "Error in conversion"
    end
  end
end