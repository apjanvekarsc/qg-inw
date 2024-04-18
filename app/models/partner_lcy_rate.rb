class PartnerLcyRate < ApplicationRecord
  include Approval2::ModelAdditions

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  belongs_to :partner, :foreign_key =>'partner_code', :primary_key => 'code', :class_name => 'Partner'

  validates_presence_of :partner_code, :rate
  validates_uniqueness_of :partner_code, :scope => :approval_status
  validates :partner_code, format: {with: /\A[A-Za-z0-9]+\z/, message: "invalid format - expected format is : {[A-Za-z0-9\s]}"}, length: {maximum: 10, minimum: 1}
  validates :rate, :numericality => { :greater_than_or_equal_to => 1 }
  validate :value_of_lcy_rate

  def value_of_lcy_rate
    errors.add(:rate, "is invalid, only two digits are allowed after decimal point") if rate.to_f != rate.to_f.round(2)
    errors.add(:rate, "can't be greater than 1 because needs_lcy_rate is N for the guideline") if partner.try(:guideline).try(:needs_lcy_rate) == "N" && rate > 1.0
  end
  def self.mtss_url
    mtss_url = ApplicationRecord.connection.execute("select value from esb_config where key='mtss_rate_update_url'")
    return mtss_url.fetch.first
  end

  def self.read_username
    username = ApplicationRecord.connection.execute("select http_username from sc_backends where code='SC_PARTNER_LCY_RATE'")
    return username.fetch.first
  end

  def self.read_password
    password = ApplicationRecord.connection.execute("select http_password from sc_backends where code='SC_PARTNER_LCY_RATE'")
    return DecPassGenerator.new(password.fetch.first,ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_decrypted_data if password.present?
  end
end
