# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:code) {|n| "%010i" % "#{n}" }
  factory :partner do
    code 
    name "MyString"
    enabled 'Y'
    tech_email_id "foo@ruby.com"
    ops_email_id "foo@ruby.com"
    account_no "1234567890123456"
    account_ifsc "abcd0123456"
    txn_hold_period_days 0
    identity_user_id { Factory(:iam_cust_user, approval_status: 'A').username }
    low_balance_alert_at 1.5
    remitter_sms_allowed "MyString"
    remitter_email_allowed "MyString"
    beneficiary_sms_allowed "MyString"
    beneficiary_email_allowed "MyString"
    allow_neft "N"
    allow_rtgs "N"
    allow_imps "N"
    add_req_ref_in_rep "Y"
    add_transfer_amt_in_rep "Y"
    created_by "MyString"
    updated_by "MyString"
    customer_id 1234
    mmid 1234534
    mobile_no 1234567899
    country "USA"
    address_line1 "addr1"
    address_line2 "addr2"
    address_line3 "addr3"
    will_send_id 'Y'
    guideline_id { Factory(:inw_guideline, approval_status: 'A').id }
    auto_reschdl_to_next_wrk_day 'N'
  end
end
