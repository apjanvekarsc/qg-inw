require 'will_paginate/array'

class InwardRemittancesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include InwardRemittanceHelper

  def index
    if request.get?
      # only 'safe/non-personal' parameters are allowed as search parameters in a query string
      @searcher = InwardRemittanceSearcher.new(params.permit(:partner_id, :request_no, :wl_id, :wl_id_for, :page))
    else
      # rest parameters are in post
      @searcher = InwardRemittanceSearcher.new(search_params)
    end
    @records = @searcher.paginate
  end

  def index
    if params[:advanced_search].present?
      inward_remittances = find_inward_remittances(params).order("id DESC")
    else
      inward_remittances = (params[:approval_status].present? and params[:approval_status] == 'U') ? InwardRemittance.unscoped.where("approval_status =?",'U').order("id desc") : InwardRemittance.order("id desc")
    end
    @inward_remittances = inward_remittances.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
  
  # to reuse the view
  def identity
    inw_txn = InwardRemittance.find(params[:id])
    @identities = InwIdentity.where(id: params[:id_id]).paginate(:per_page => 10, :page => params[:page]) rescue []
    render '_identities'
  end
  
  # to attempt a release of an on-hold txn
  def release
    inw_txn = InwardRemittance.find(params[:id])
    inw_txn.release
  rescue ::Fault::ProcedureFault, OCIError => e
   flash[:alert] = "#{e.message}"    
  ensure
   redirect_to inw_txn
  end

  def remitter_identities
    @user = current_user
    inward_remittance = InwardRemittance.find_by_id(params[:id])
    identities = inward_remittance.remitter_identities
    @identities = identities.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def beneficiary_identities
    @user = current_user
    inward_remittance = InwardRemittance.find_by_id(params[:id])
    identities = inward_remittance.beneficiary_identities
    @identities = identities.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @inward_remittance = InwardRemittance.find(params[:id])
    values = find_logs(params, @inward_remittance)
    @values_count = values.count(:id)
    @values = values.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  private    
    def search_params
      params.require(:inward_remittance_searcher).permit( :page, :partner_id, :status_code, :notify_status, :request_no,
      :rmtr_code, :bene_account_no, :bene_account_ifsc, :bank_ref, :rmtr_full_name, :req_transfer_type, :transfer_type,
      :from_transfer_amount, :to_transfer_amount, :from_req_timestamp, :to_req_timestamp, :wl_id, :wl_id_for)
    end
  
  def inward_remittance_params
    params.require(:inward_remittance).permit(:attempt_no, :bank_ref, :bene_account_ifsc, :bene_account_no, :bene_address1, 
                  :bene_address2, :bene_address3, :bene_city, :bene_country, :bene_email_id, 
                  :bene_first_name, :bene_full_name, :bene_identity_count, :bene_last_name, 
                  :bene_mobile_no, :bene_postal_code, :bene_ref, :bene_state, :partner_code, 
                  :purpose_code, :rep_no, :rep_timestamp, :rep_version, :req_no, :req_timestamp, 
                  :req_version, :review_pending, :review_reqd, :rmtr_address1, :rmtr_address2, 
                  :rmtr_address3, :rmtr_city, :rmtr_country, :rmtr_email_id, :rmtr_first_name, 
                  :rmtr_full_name, :rmtr_identity_count, :rmtr_last_name, :rmtr_mobile_no, 
                  :rmtr_postal_code, :rmtr_state, :rmtr_to_bene_note, :status_code, 
                  :transfer_amount, :transfer_ccy, :transfer_type)
  end
end