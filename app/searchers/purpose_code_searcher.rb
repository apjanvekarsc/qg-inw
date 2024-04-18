class PurposeCodeSearcher < Searcher
  attr_searchable :page, :approval_status, :code, :is_enabled
  
  as_enum :is_enabled, [:Y, :N], map: :string, source: :is_enabled
end