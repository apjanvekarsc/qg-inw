require 'will_paginate/array'

class PurposeCodesController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include PurposeCodeHelper
  
  def new
    @purpose_code = PurposeCode.new
  end

  def create
    @purpose_code = PurposeCode.new(params[:purpose_code])
    @purpose_code.disallowed_rem_types=@purpose_code.convert_disallowed_rem_types_to_string(params[:purpose_code][:disallowed_rem_types])
    @purpose_code.disallowed_bene_types=@purpose_code.convert_disallowed_bene_types_to_string(params[:purpose_code][:disallowed_bene_types])
    if !@purpose_code.valid?
      render "new"
    else
      @purpose_code.created_by = current_user.id
      @purpose_code.save!
      flash[:alert] = 'Purpose Code successfully created and is pending for approval'
      redirect_to @purpose_code
    end
  end

  def update
    @purpose_code = PurposeCode.unscoped.find_by_id(params[:id])
    @purpose_code.attributes = params[:purpose_code]
   @purpose_code.disallowed_rem_types=@purpose_code.convert_disallowed_rem_types_to_string(params[:purpose_code][:disallowed_rem_types])
   @purpose_code.disallowed_bene_types=@purpose_code.convert_disallowed_bene_types_to_string(params[:purpose_code][:disallowed_bene_types])
    if !@purpose_code.valid?
      render "edit"
    else
      @purpose_code.updated_by = current_user.id
      @purpose_code.save!
      flash[:alert] = 'Purpose Code successfully modified and is pending for approval'
      redirect_to @purpose_code
    end
    rescue ActiveRecord::StaleObjectError
      @purpose_code.reload
      flash[:alert] = 'Someone edited the purpose_code the same time you did. Please re-apply your changes to the purpose_code.'
      render "edit"
  end 

  def show
    @purpose_code = PurposeCode.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      purpose_codes = find_purpose_codes(params).order("id DESC")
    else
      purpose_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? PurposeCode.unscoped.where("approval_status =?",'U').order("id desc") : PurposeCode.order("id desc")
    end
    @purpose_codes = purpose_codes.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @purpose_code = PurposeCode.unscoped.find(params[:id]) rescue nil
    @audit = @purpose_code.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  private    
    def search_params
      params.require(:purpose_code_searcher).permit( :page, :approval_status, :code, :is_enabled)
    end 


  def purpose_code_params
    params.require(:purpose_code).permit(:code, :created_by, :daily_txn_limit, :description, {:disallowed_bene_types => []}, 
                                         {:disallowed_rem_types => []}, :is_enabled, :lock_version, :txn_limit, :updated_by,
                                         :mtd_txn_cnt_self, :mtd_txn_limit_self, :mtd_txn_cnt_sp, :mtd_txn_limit_sp, :rbi_code,
                                         :pattern_beneficiaries, :pattern_allowed_benes, :approved_id, :approved_version, :guideline_id)
  end
  
end