# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define(:inward_remittance) do |i|
  i.sequence(:req_no) { |n| "key_#{n}" }
    i.req_version "MyString"
    i.req_timestamp "2015-04-20 15:12:44"
    i.partner_code "MyString"
    i.rmtr_full_name "MyString"
    i.rmtr_address1 "MyString"
    i.rmtr_address2 "MyString"
    i.rmtr_address3 "MyString"
    i.rmtr_postal_code "MyString"
    i.rmtr_city "MyString"
    i.rmtr_state "MyString"
    i.rmtr_country "MyString"
    i.rmtr_email_id "MyString"
    i.rmtr_mobile_no "MyString"
    i.rmtr_identity_count 1
    i.bene_full_name "MyString"
    i.bene_address1 "MyString"
    i.bene_address2 "MyString"
    i.bene_address3 "MyString"
    i.bene_postal_code "MyString"
    i.bene_city "MyString"
    i.bene_state "MyString"
    i.bene_country "MyString"
    i.bene_email_id "MyString"
    i.bene_mobile_no "MyString"
    i.bene_identity_count 1
    i.bene_account_no "MyString"
    i.bene_account_ifsc "MyString"
    i.transfer_type "MyString"
    i.transfer_ccy "MyString"
    i.transfer_amount 1.5
    i.rmtr_to_bene_note "MyString"
    i.purpose_code "MyString"
    i.status_code "MyString"
    i.bank_ref "MyString"
    i.rep_no "MyString"
    i.rep_version "MyString"
    i.rep_timestamp "2015-04-20 15:12:44"
    i.attempt_no 1.5
end
