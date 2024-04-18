class InwGuideline < ApplicationRecord
  include Approval2::ModelAdditions
  
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  
  before_validation :squish_disallowed_products
  before_save :set_txn_cnt, if: lambda {"ytd_txn_cnt_bene.nil?"}
  
  validates_uniqueness_of :code, scope: :approval_status
  validates_presence_of :code, :allow_neft, :allow_imps, :allow_rtgs
  validates_numericality_of :ytd_txn_cnt_bene, {:greater_than_or_equal_to => 0, :allow_blank => true}
  validates_format_of :disallowed_products, :with => /\A\d[\d\-\(\)\s\r\n]*\z/, :allow_blank => true
  validates :code, format: {with: /\A[A-Za-z0-9]+\z/, message: "invalid format - expected format is : {[A-Za-z0-9\s]}"}

  def squish_disallowed_products
    self.disallowed_products = disallowed_products.squeeze(' ').strip.each_line.reject{|x| x.strip == ''}.join unless:  lambda{ disallowed_products.nil?}
  end
  
  def set_txn_cnt
    self.ytd_txn_cnt_bene = 0
  end
end
