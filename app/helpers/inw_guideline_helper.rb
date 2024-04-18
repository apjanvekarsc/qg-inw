module InwGuidelineHelper

  def find_inw_guidelines(params)
    inw_guidelines = (params[:approval_status].present? and params[:approval_status] == 'U') ? InwGuideline.unscoped : InwGuideline
    inw_guidelines = inw_guidelines.where("code=?",params[:code]) if params[:code].present?
    inw_guidelines
  end
end
