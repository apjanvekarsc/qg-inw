class WhitelistedIdentity < ApplicationRecord
  include Approval2::ModelAdditions
  
  audited
  attr_accessor :txn_identity_no

  has_many :attachments, :as => :attachable
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  belongs_to :inward_remittance, :foreign_key => 'first_used_with_txn_id', :class_name => 'InwardRemittance'
  belongs_to :partner

  accepts_nested_attributes_for :attachments

  validates_presence_of :partner, :id_for, :created_for_req_no, :created_by, :id_type, :id_number, :id_expiry_date, :full_name
  validates :id_country, format: {with: /\A[A-Z]{2}+\z/, :message => 'Invalid format, expected format is : {[A-Z]{2}}' }, allow_blank: true
  
  validate :validate_whitelisted_identity_on_create, :on => :create
  
  before_create :set_defaults_for_create
  
  # the after_save callbacks call database packages which arent avialable in the test environment
  after_save :release unless Rails.env.test? 
  
  private   
  def set_defaults_for_create
    partner = Partner.find_by_id(self.partner_id)
    inw_txn = InwardRemittance.find_last_attempt_for_req_no(partner.code, self.created_for_req_no)
    self.created_for_txn_id = inw_txn.id
    
    if partner.will_send_id == 'N'
      if id_for == 'B'
        self.bene_account_no = inw_txn.bene_account_no
        self.bene_account_ifsc = inw_txn.bene_account_ifsc
      else
        self.rmtr_code = inw_txn.rmtr_code
      end
    end
    
    self.is_revoked = 'N'
    self.is_verified = 'Y'
    self.verified_at = self.created_at
    self.verified_by = self.created_by
    self.times_used = 0
  end  
  
  # on the approval of the creation of the whitelisted identity a the association is done and a release is attempted
  def release    
    if self.approval_status == 'A' && (self.last_action = 'C' or self.is_revoked_changed?(from: 'Y', to: 'N'))
      auto_match_and_release
    end
  end
  
  def auto_match_and_release
    plsql.pk_qg_inw_wl_service.auto_match_and_release(pi_broker_uuid: ENV['CONFIG_IIB_SMTP_BROKER_UUID'], pi_wl_id: self.id)
  end

  def validate_whitelisted_identity_on_create
    # partner and created_for_req_no are mandatory, and traopped with a presence validations
    validate_whitelisted_identity if self.partner.present? && self.created_for_req_no.present?
  end
  
  def validate_whitelisted_identity
    inw_txn = InwardRemittance.find_last_attempt_for_req_no(self.partner.code, self.created_for_req_no)

    errors.add(:id_for, "should be either R or B") unless ['R','B'].include?(id_for)
    errors.add(:created_for_req_no, "no transaction found for req_no") if inw_txn.nil?
    errors.add(:id_expiry_date,"should not be less than today's date") if !id_expiry_date.nil? and id_expiry_date < Time.zone.today
    errors.add(:id_expiry_date,"should not be less than issue date") if !id_expiry_date.nil? and !id_issue_date.nil? and id_expiry_date < id_issue_date
    errors.add(:id_type,"should not be the reserved word partnerProvidedID") if id_type == 'partnerProvidedID'

    unless inw_txn.nil?
      if id_for == 'B'
        errors.add(:full_name, "the name entered does not match the beneficiary name #{inw_txn.bene_full_name}") if inw_txn.bene_full_name != full_name
      else
        errors.add(:full_name, "the name entered does not match the remitter name #{inw_txn.rmtr_full_name}") if inw_txn.rmtr_full_name != full_name
      end
    end
  end 
end