class InwardRemittancesLock < ApplicationRecord
  # attr_accessible :partner_code, :req_no

  validates_uniqueness_of :partner_code, :req_no

  has_one :partner, :primary_key => 'partner_code', :foreign_key => 'code'
  has_one :inward_remittance, :primary_key => 'req_no', :foreign_key => 'req_no'
end