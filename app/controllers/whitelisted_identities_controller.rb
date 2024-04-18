require 'will_paginate/array'
include AttachmentsHelper

class WhitelistedIdentitiesController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include WhitelistedIdentityHelper

  def new
    @whitelisted_identity = WhitelistedIdentity.new

    # for creation of a whitelisted identity for a transaction
    if params[:inw_id].present?
      inw_txn = InwardRemittance.find_by_id(params[:inw_id])

      @whitelisted_identity.id_for = params[:id_for]
    # for creation of a whitelisted identity for a identity
    elsif params[:id_id].present? && !(inw_identity = InwIdentity.find_by_id(params[:id_id])).nil?
      inw_txn = inw_identity.inward_remittance

      @whitelisted_identity.id_for = inw_identity.id_for
      @whitelisted_identity.id_type = inw_identity.id_type
      @whitelisted_identity.id_number = inw_identity.id_number
      @whitelisted_identity.id_country = inw_identity.id_country
      @whitelisted_identity.id_issue_date = inw_identity.id_issue_date
      @whitelisted_identity.id_expiry_date = inw_identity.id_expiry_date
    end

    # fields set by default when we know the transaction for which the whitelisted is to be created
    unless inw_txn.nil?
      @whitelisted_identity.partner_id = inw_txn.partner.id
      @whitelisted_identity.created_for_req_no = inw_txn.req_no
      if @whitelisted_identity.id_for == 'R'
        @whitelisted_identity.full_name = inw_txn.rmtr_full_name
      else
        @whitelisted_identity.full_name = inw_txn.bene_full_name
      end
    end

    @user = current_user
  end

  def create
    @whitelisted_identity = WhitelistedIdentity.new(params[:whitelisted_identity])
    @whitelisted_identity.created_by = @current_user.id
    if !@whitelisted_identity.valid?
      render "new"
    else
      @whitelisted_identity.created_by = current_user.id
      begin
        if @whitelisted_identity.save!
          EmailAlert.send_email(@whitelisted_identity.inward_remittance,@whitelisted_identity.partner.ops_email_id) rescue nil
        end
        flash[:alert] = 'Identity successfully verified, pending approval'
      rescue ::Fault::ProcedureFault, OCIError => e
       flash[:alert] = "#{e.message}"
      end
      redirect_to whitelisted_identities_path
    end
  end

  def index
    if params[:advanced_search].present?
      whitelisted_identities = find_whitelisted_identities(params).order("whitelisted_identities.id DESC")
    else
      whitelisted_identities = (params[:approval_status].present? and params[:approval_status] == 'U') ? WhitelistedIdentity.unscoped.where("approval_status =?",'U').order("id desc") : WhitelistedIdentity.order("id desc")
    end
    @whitelisted_identities = whitelisted_identities.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def show
    @whitelisted_identity = WhitelistedIdentity.unscoped.find_by_id(params[:id])
  end

  def download_attachment
    attachment = Attachment.find_by_id(params[:attachment_id])
    if attachment.nil?
     flash[:notice] = "File not found"
     redirect_to :back
    elsif attachment.file.blank? || File.file?(attachment.file.path) == false
      flash[:notice] = 'The attachment has been archived, and is no longer available for download.'
      redirect_to attachment.attachable
    else
      whitelisted_identity = attachment.attachable
      normal_attachment(attachment)
    end
  end

  def approve
  rescue ::Fault::ProcedureFault, OCIError => e
   flash[:alert] = "#{e.message}"
  ensure
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  def ratify
    whitelisted_identity = WhitelistedIdentity.find(params[:id])
    whitelisted_identity.is_revoked = 'N'
    flash[:alert] = !whitelisted_identity.save ? whitelisted_identity.errors.full_messages : 'WhitesListed Identity successfully ratified'
  rescue ActiveRecord::StaleObjectError
    flash[:alert] = 'Someone edited the whitelisted identity the same time you did. Please re-apply your changes.'
  ensure
    redirect_to whitelisted_identities_path
  end

  def revoke
    whitelisted_identity = WhitelistedIdentity.find(params[:id])
    whitelisted_identity.is_revoked = 'Y'
    if !whitelisted_identity.save
      flash[:alert] = whitelisted_identity.errors.full_messages
    else
      flash[:alert] = 'WhitesListed Identity successfully revoked'
    end
  rescue ::Fault::ProcedureFault, OCIError => e
   flash[:alert] = "#{e.message}"
  rescue ActiveRecord::StaleObjectError
    flash[:alert] = 'Someone edited the whitelisted identity the same time you did. Please re-apply your changes.'
  ensure
    redirect_to whitelisted_identities_path
  end

  def audit_logs
    @record = WhitelistedIdentity.unscoped.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end

  private
    def search_params
      params.require(:whitelisted_identity_searcher).permit( :page, :approval_status, :partner_code, :name, :rmtr_code, :bene_account_no, :bene_account_ifsc)
    end

  def whitelisted_identity_params
    params.require(:whitelisted_identity).permit(:created_by, :full_name, :id_country,
                                                 :id_issue_date, :id_expiry_date, :id_number, :id_type,
                                                 :lock_version, :partner_id,
                                                 :updated_by, {:attachments_attributes => [:note, :user_id, :file, :_destroy]},
                                                 :approved_id, :approved_version, :created_for_req_no, :id_for)
  end
end
