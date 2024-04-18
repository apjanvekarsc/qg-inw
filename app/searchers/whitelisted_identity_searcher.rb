class WhitelistedIdentitySearcher < Searcher
  attr_searchable :page, :approval_status, :partner_code, :name, :rmtr_code, :bene_account_no, :bene_account_ifsc
  validate :validate_search_criteria
  
  private
  def validate_search_criteria
    if partner_code.blank? && (name.present? || rmtr_code.present? || bene_account_ifsc.present? || bene_account_no.present? )
      errors[:base] << "Partner code is mandatory when using advanced search"
    elsif partner_code.present?
      partner = Partner.find_by(code: partner_code)
      if partner.present? && partner.will_send_id == 'Y' && (rmtr_code.present? || bene_account_ifsc.present? || bene_account_no.present? )
        errors[:base] << "Search is not allowed on ID Detail (i.e., RemitterCode, Beneficiary Account No and Beneficiary IFSC) for this Partner since Will Send ID is not N"
      end
    end
  end
  
  def find
    reln = approval_status == 'U' ? WhitelistedIdentity.joins(:partner).unscoped.where("approval_status =?",'U').order("whitelisted_identities.id desc") : WhitelistedIdentity.joins(:partner).order("whitelisted_identities.id desc")
    reln = reln.where("partners.code IN (?)", partner_code.split(",").collect(&:strip)) if partner_code.present?
    reln = reln.where("whitelisted_identities.full_name IN (?)", name.split(",").collect(&:strip)) if name.present?
    reln
  end
end