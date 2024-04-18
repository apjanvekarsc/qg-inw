# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :whitelisted_identity do
    partner_id { @partner = Factory(:partner, will_send_id: 'N', approval_status: 'A').id }
    full_name "MyString"
    first_name "Foo"
    last_name "Bar"
    id_type "Passport"
    id_number "G12424"
    id_country "IN"
    id_issue_date "2015-04-20"
    id_expiry_date "2040-05-19"
    is_verified "Y"
    verified_at "2015-04-20"
    verified_by {Factory(:user).id}
    first_used_with_txn_id 1
    last_used_with_txn_id 1
    times_used 1
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    created_for_txn_id 1
    lock_version 1
    created_for_req_no { Factory(:inward_remittance, partner_code: (Partner.find_by_id(@partner).code), rmtr_code: '12351', rmtr_full_name: 'MyString').req_no }
    rmtr_code '12351'
    id_for 'R'
  end
end
