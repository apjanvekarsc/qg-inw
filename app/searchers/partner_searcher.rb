class PartnerSearcher < Searcher
  attr_searchable :page, :approval_status, :enabled, :code, :account_no, :allow_neft, :rtgs_allow, :imps_allow
  
  as_enum :enabled, [:Y, :N], map: :string, source: :status_code
  as_enum :allow_neft, [:Y, :N], map: :string, source: :allow_neft
  as_enum :rtgs_allow, [:Y, :N], map: :string, source: :rtgs_allow
  as_enum :imps_allow, [:Y, :N], map: :string, source: :imps_allow
  
  
  def find
    reln = Partner.unscoped.order('id desc')
    reln = reln.where("approval_status = ?", approval_status) if approval_status.present?
    reln = reln.where("allow_imps = ?", imps_allow) if imps_allow.present?
    reln = reln.where("allow_rtgs = ?", rtgs_allow) if rtgs_allow.present?
    reln
  end
end