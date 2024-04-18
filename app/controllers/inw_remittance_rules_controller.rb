require 'will_paginate/array'

class InwRemittanceRulesController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  
  def new
    @inw_remittance_rule = InwRemittanceRule.new
  end

  def create
    @inw_remittance_rule = InwRemittanceRule.new(params[:inw_remittance_rule])
    if !@inw_remittance_rule.valid?
      render "new"
    else
      @inw_remittance_rule.created_by = current_user.id
      @inw_remittance_rule.save
      flash[:alert] = 'Rule successfully created and is pending for approval'
      redirect_to @inw_remittance_rule
    end
  end

  def update
    @inw_remittance_rule = InwRemittanceRule.unscoped.find_by_id(params[:id])
    @inw_remittance_rule.attributes = params[:inw_remittance_rule]
    if !@inw_remittance_rule.valid?
      render "edit"
    else
      @inw_remittance_rule.updated_by = current_user.id
      @inw_remittance_rule.save
      flash[:alert] = 'Rule successfully modified and is pending for approval'
      redirect_to @inw_remittance_rule
    end
    rescue ActiveRecord::StaleObjectError
      @inw_remittance_rule.reload
      flash[:alert] = 'Someone edited the rule the same time you did. Please re-apply your changes to the rule.'
      render "edit"
  end

  def index
    @inw_remittance_rules_count = @inw_remittance_rules.count
  end

  def show
    @inw_remittance_rule = InwRemittanceRule.unscoped.find_by_id(params[:id])
  end

  def audit_logs
    @rule = InwRemittanceRule.unscoped.find(params[:id]) rescue nil
    @audit = @rule.audits[params[:version_id].to_i] rescue nil
  end

  def error_msg
    flash[:alert] = "Rule is not yet configured"
    redirect_to :root
  end
  
  def approve
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  private

  def inw_remittance_rule_params
    params.require(:inw_remittance_rule).permit(:pattern_individuals, :pattern_corporates, :pattern_beneficiaries, :created_by, :updated_by, :lock_version, :pattern_salutations, :pattern_remitters, :approved_id, :approved_version)
  end
end