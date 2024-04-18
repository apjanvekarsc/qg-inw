# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bank do
    sequence(:ifsc) {|n| "abcd0" + "%06i" % "#{n}" }
    name "MyString"
    imps_enabled false
  end
end
