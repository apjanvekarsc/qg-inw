class Bank < ApplicationRecord
  include Approval2::ModelAdditions
  
  validates_presence_of :ifsc, :name
  validates_uniqueness_of :ifsc, :scope => :approval_status
  validates :ifsc, format: {with: /\A[A-Z|a-z]{4}[0][A-Za-z0-9]{6}+\z/, :allow_blank => true, message: "invalid format - expected format is : {[A-Z|a-z]{4}[0][A-Za-z0-9]{6}}" }
  validates :name, format: {with: /\A[A-Za-z\s]+\z/, message: "invalid format - expected format is : {[A-Za-z\s]}"}
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  def imps_enabled?
    imps_enabled ? 'Y' : 'N'
  end
end