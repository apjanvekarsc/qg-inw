require 'will_paginate/array'

class InwGuidelinesController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include InwGuidelineHelper

  def create
    @inw_guideline = InwGuideline.new(params[:inw_guideline])
    if !@inw_guideline.valid?
      render "edit"
    else
      @inw_guideline.created_by = current_user.id
      @inw_guideline.save!

      flash[:alert] = 'InwGuideline successfully created and is pending for approval'
      redirect_to @inw_guideline
    end
  end

  def update
    @inw_guideline = InwGuideline.unscoped.find_by_id(params[:id])
    @inw_guideline.attributes = params[:inw_guideline]
    if !@inw_guideline.valid?
      render "edit"
    else
      @inw_guideline.updated_by = current_user.id
      @inw_guideline.save!
      flash[:alert] = 'InwGuideline successfully modified and is pending for approval'
      redirect_to @inw_guideline
    end
    rescue ActiveRecord::StaleObjectError
      @inw_guideline.reload
      flash[:alert] = 'Someone edited the inw_guideline the same time you did. Please re-apply your changes to the inw_guideline.'
      render "edit"
  end 

  def show
    @inw_guideline = InwGuideline.unscoped.find_by_id(params[:id])
    respond_to do |format|
      format.json {render json: @inw_guideline.attributes}
      format.html
    end
  end

  def index
    if params[:advanced_search].present?
      @inw_guidelines = find_inw_guidelines(params).order("id desc").paginate(:per_page => 10, :page => params[:page])
    else
      @inw_guidelines ||= InwGuideline.order("id desc").paginate(:per_page => 10, :page => params[:page])
    end
    @inw_guidelines_count = @inw_guidelines.count
  end

  def audit_logs
    @inw_guideline = InwGuideline.unscoped.find(params[:id]) rescue nil
    @audit = @inw_guideline.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  private

  def inw_guideline_params
    params.require(:inw_guideline).permit(:code, :allow_neft, :allow_imps, :allow_rtgs, :ytd_txn_cnt_bene, :disallowed_products,
                                          :needs_lcy_rate, :is_enabled, :created_by, :updated_by, :created_at, :updated_at, 
                                          :lock_version, :approval_status, :approved_id, :approved_version)
  end
end