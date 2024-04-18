class InwAuditStep < ApplicationRecord
  belongs_to :inw_auditable, :polymorphic => true
end
