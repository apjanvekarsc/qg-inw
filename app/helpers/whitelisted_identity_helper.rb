module WhitelistedIdentityHelper	

	def find_whitelisted_identities(params)
    whitelisted_identities = (params[:approval_status].present? and params[:approval_status] == 'U') ? WhitelistedIdentity.unscoped.joins(:partner) : WhitelistedIdentity.joins(:partner)
    whitelisted_identities = whitelisted_identities.where("partners.code IN (?)", params[:partner_code].split(",").collect(&:strip)) if params[:partner_code].present?
    whitelisted_identities = whitelisted_identities.where("whitelisted_identities.full_name IN (?)", params[:name].split(",").collect(&:strip)) if params[:name].present?
    whitelisted_identities = whitelisted_identities.where("rmtr_code IN (?)",params[:rmtr_code].split(",").collect(&:strip)) if params[:rmtr_code].present?
    whitelisted_identities = whitelisted_identities.where("bene_account_no IN (?)",params[:bene_account_no].split(",").collect(&:strip)) if params[:bene_account_no].present?
    whitelisted_identities = whitelisted_identities.where("bene_account_ifsc IN (?)",params[:bene_account_ifsc].split(",").collect(&:strip)) if params[:bene_account_ifsc].present?
    whitelisted_identities
  end

end