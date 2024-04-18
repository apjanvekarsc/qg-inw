require 'spec_helper'

describe InwardRemittancesLock do
  context 'association' do
    it { should have_one(:partner) }
    it { should have_one(:inward_remittance) }
  end

  # context 'validation' do
  #   it do
  #     Factory(:inward_remittances_lock)
  #     should validate_uniqueness_of(:partner_code)
  #     should validate_uniqueness_of(:req_no)
  #   end
  # end
end
