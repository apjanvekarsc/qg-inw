# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inw_audit_log do
    inward_remittance_id 1
    request_bitstream "MyText"
    reply_bitstream "MyText"
  end
end
