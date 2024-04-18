# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inw_guideline do
    sequence(:code) {|n| "%010i" % "#{n}" }
    allow_neft 'Y'
    allow_imps 'Y'
    allow_rtgs 'Y'
    ytd_txn_cnt_bene 999999
    disallowed_products '100'
    needs_lcy_rate 'N'
    approval_status 'U'
  end
end