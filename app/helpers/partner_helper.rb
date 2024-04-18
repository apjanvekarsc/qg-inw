module PartnerHelper	

	def find_partners(params)
    partners = (params[:approval_status].present? and params[:approval_status] == 'U') ? Partner.unscoped : Partner
    partners = partners.where("enabled = ?", params[:enabled]) if params[:enabled].present?
    partners = partners.where("code IN (?)",params[:code].split(",").collect(&:strip)) if params[:code].present?
    partners = partners.where("account_no IN (?)",params[:account_no].split(",").collect(&:strip)) if params[:account_no].present?
    partners = partners.where("allow_neft = ?", params[:allow_neft]) if params[:allow_neft].present?
    partners = partners.where("allow_rtgs = ?", params[:rtgs_allow]) if params[:rtgs_allow].present?
    partners = partners.where("allow_imps = ?", params[:imps_allow]) if params[:imps_allow].present?
    partners
  end

end