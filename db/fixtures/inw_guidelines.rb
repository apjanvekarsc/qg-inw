InwGuideline.seed_once(:code) do |s|
  s.id = 1
  s.code = 'RDA'
  s.is_enabled = 'Y'
  s.allow_neft = 'Y'
  s.allow_imps = 'Y'
  s.allow_rtgs = 'Y'
  s.ytd_txn_cnt_bene = 9999999999
  s.needs_lcy_rate = 'N'
  s.approval_status = 'A'
  s.created_by = 'Q'
end

InwGuideline.seed_once(:code) do |s|
  s.id = 2
  s.code = 'MTSS'
  s.is_enabled = 'Y'
  s.allow_neft = 'Y'
  s.allow_imps = 'Y'
  s.allow_rtgs = 'N'
  s.ytd_txn_cnt_bene = 25
  s.disallowed_products = 100
  s.needs_lcy_rate = 'Y'
  s.approval_status = 'A'
  s.created_by = 'Q'
end