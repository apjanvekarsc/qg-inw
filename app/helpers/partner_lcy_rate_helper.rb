module PartnerLcyRateHelper

  def find_partner_lcy_rates(params)
    partner_lcy_rates = (params[:approval_status].present? and params[:approval_status] == 'U') ? PartnerLcyRate.unscoped : PartnerLcyRate
    partner_lcy_rates = partner_lcy_rates.where("partner_code IN (?)", params[:partner_code].split(",").collect(&:strip)) if params[:partner_code].present?
    partner_lcy_rates
  end

end