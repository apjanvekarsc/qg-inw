class InwardRemittance < ApplicationRecord
  has_one :partner, :primary_key => 'partner_code', :foreign_key => 'code'
  has_one :purpose, :class_name => 'PurposeCode', :primary_key => 'purpose_code', :foreign_key => 'code'

  has_many :remitter_identities, -> { where id_for: 'R'}, :class_name => 'InwIdentity', :foreign_key => 'inw_remittance_id'
  has_many :beneficiary_identities, -> { where id_for: 'B'}, :class_name => 'InwIdentity', :foreign_key => 'inw_remittance_id'
  has_many :identities, :class_name => 'InwIdentity', :foreign_key => 'inw_remittance_id'

  has_one :inw_audit_log
  has_one :inward_remittances_lock
  has_many :audit_steps, :class_name => 'InwAuditStep', :as => :inw_auditable
  
  belongs_to :rmtr_wl_identity, class_name: 'WhiteListedIdentity', foreign_key: 'rmtr_wl_id'
  belongs_to :bene_wl_identity, class_name: 'WhiteListedIdentity', foreign_key: 'bene_wl_id'
  

  validates_presence_of :req_no, :req_version, :req_timestamp, :partner_code, :rmtr_identity_count, 
                        :bene_identity_count, :attempt_no

  florrick do
    string :req_no
  end

  def self.find_last_attempt_for_req_no(partner_code, req_no)
    where(req_no: req_no, partner_code: partner_code).order("attempt_no desc").first
  end
  
  def remitter_address
    rmtr_address1.to_s + " " + rmtr_address2.to_s + " " + rmtr_address3.to_s
  end

  def beneficiary_address
    bene_address1.to_s + " " + bene_address2.to_s + " " + bene_address3.to_s
  end

  def reply_time
    ((rep_timestamp - req_timestamp)/1.minute).round rescue '0'
  end

  def self_transfer?
    is_self_transfer=='Y' ? true : false
  end

  def partner_name
    partner.try(:name) rescue nil
  end

  def same_party_transfer?
    is_same_party_transfer=='Y' ? true : false
  end
  
  def release
    return if Rails.env.test?
    result = plsql.pk_qg_inw_wl_service.try_release(pi_broker_uuid: ENV['CONFIG_IIB_SMTP_BROKER_UUID'], pi_txn_id: self.id, po_fault_code: nil, po_fault_subcode: nil, po_fault_reason: nil)
    raise ::Fault::ProcedureFault.new(OpenStruct.new(code: result[:po_fault_code], subCode: result[:po_fault_subcode], reasonText: "#{result[:po_fault_reason]}")) if result[:po_fault_code].present?    
  end

end
