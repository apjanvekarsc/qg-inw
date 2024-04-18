require 'will_paginate/array'

class PartnersController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include PartnerHelper

  def new
    @partner = Partner.new
  end

  def create    
    @partner = Partner.new(params[:partner])

    if !@partner.valid?
      render :new
    else
      if params[:partner][:service_name] == "RPL" ||  params[:partner][:service_name] == "ANTFN"
        @partner.service_name = "INW"
        if params[:partner][:sender_rc].present? && params[:partner][:service_name] == "ANTFN"
          @partner.sender_rc = ""
        end
      end
      @partner.created_by = current_user.id
      @partner.save!

      flash[:alert] = 'Partner successfully created and is pending for approval'
      redirect_to @partner
    end
  end

  def update
    @partner = Partner.find_by_id(params[:id])
    @partner.attributes = params[:partner]
    if !@partner.valid?
      render "edit"
    else
      if (@partner.service_name !="RPL" && @partner.sender_rc != nil)
        @partner.sender_rc = ""
      end

      if @partner.service_name == "RPL" || @partner.service_name == "ANTFN"
        @partner.service_name = "INW"
      end
      # binding.pry
      @partner.updated_by = current_user.id
      @partner.save! 
      flash[:alert] = 'Partner successfully modified and is pending for approval'
      redirect_to @partner
    end
    rescue ActiveRecord::StaleObjectError
      @partner.reload
      flash[:alert] = 'Someone edited the partner the same time you did. Please re-apply your changes to the partner.'
      render "edit"
  end

  def show
    @partner = Partner.find_by_id(params[:id])    
  end

  def index
    if params[:advanced_search].present?
      partners = find_partners(params).order("id DESC")
    else
      partners = (params[:approval_status].present? and params[:approval_status] == 'U') ? Partner.where("approval_status =?",'U').order("id desc") : Partner.order("id desc")
    end
    @partners = partners.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @partner = Partner.find(params[:id]) rescue nil
    @audit = @partner.audits[params[:version_id].to_i] rescue nil
  end

  def approve
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  def resend_notification
    @partner = Partner.find(params[:id]) rescue nil
    flash[:alert] = @partner.resend_setup
    redirect_to @partner
  end

  private
    def search_params
      params.require(:partner_searcher).permit( :page, :approval_status, :enabled, :code, :account_no, :allow_neft, :rtgs_allow, :imps_allow)
    end

  def partner_params
    params.require(:partner).permit(:account_ifsc, :account_no, :allow_imps, :allow_neft, :allow_rtgs,
                                    :beneficiary_email_allowed, :beneficiary_sms_allowed, :code, :created_by,
                                    :identity_user_id, :low_balance_alert_at, :name, :ops_email_id,
                                    :remitter_email_allowed, :remitter_sms_allowed, :tech_email_id,
                                    :txn_hold_period_days, :updated_by, :lock_version, :enabled, :customer_id,
                                    :country, :address_line1, :address_line2, :address_line3,:mmid, :mobile_no,
                                    :add_req_ref_in_rep, :add_transfer_amt_in_rep, :approved_id, :approved_version,
                                    :notify_on_status_change, :app_code, :service_name, :guideline_id,
                                    :will_whitelist,:will_send_id, :hold_for_whitelisting, :hold_period_days,
                                    :auto_match_rule, :notification_sent_at, :auto_reschdl_to_next_wrk_day,
                                    :reply_with_bene_name,:sender_rc, :allow_upi, :validate_vpa, :merchant_id,
                                    :connector_account, :sender_mid, :liquity_provider_id, :anchorid, :receiver_mid,
                                    :n10_notification_enabled,:neft_limit_check,:working_day_limit,
                                    :non_working_day_limit,:notify_downtime,:action_limit_breach)
  end
end
