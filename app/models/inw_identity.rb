class InwIdentity < ApplicationRecord
  belongs_to :inward_remittance, :foreign_key => 'inw_remittance_id'
  belongs_to :whitelisted_identity, :foreign_key => 'whitelisted_identity_id'

  validates :id_type, length: { maximum: 30 }
  
  def full_name
    id_for == "R" ? inward_remittance.rmtr_full_name : inward_remittance.bene_full_name
  end
end
