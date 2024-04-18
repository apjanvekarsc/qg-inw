# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inw_audit_step do
    inw_auditable_type 'InwardRemittance'
    inw_auditable_id 1
    step_no 1
    attempt_no 1
    step_name "MyString"
    status_code "MyString"
    fault_code "MyString"
    fault_subcode "MyString"
    fault_reason "MyString"
    req_reference "MyString"
    req_timestamp "2016-04-11 17:31:10"
    rep_reference "MyString"
    rep_timestamp "2016-04-11 17:31:10"
    req_bitstream "MyText"
    rep_bitstream "MyText"
    fault_bitstream "MyText"
  end
end
