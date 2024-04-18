# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:code1) {|n| "PC%02i" % "#{n}"}
  sequence(:code2) {|n| "%05i" % "#{n}"}
  factory :purpose_code do
    code FactoryGirl.generate(:code1)
    description "MyString"
    is_enabled "MyString"
    created_by ""
    updated_by "MyString"
    lock_version 1.5
    txn_limit 1.5
    daily_txn_limit 1.5
    disallowed_rem_types "MyString"
    disallowed_bene_types "MyString"
    mtd_txn_cnt_self 2
    mtd_txn_limit_self 100
    mtd_txn_cnt_sp 2
    mtd_txn_limit_sp 100
    rbi_code FactoryGirl.generate(:code2)
  end
end
