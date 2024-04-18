require 'will_paginate/array'
require 'net/http'
require 'openssl'
require 'json'

class PartnerLcyRatesController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include PartnerLcyRateHelper


  def create
    @partner_lcy_rate = PartnerLcyRate.new(params[:partner_lcy_rate])
    if !@partner_lcy_rate.valid?
      render "edit"
    else
      @partner_lcy_rate.created_by = current_user.id
      @partner_lcy_rate.save!

      flash[:alert] = 'Partner Lcy Rate successfully created and is pending for approval'
      redirect_to @partner_lcy_rate
    end
  end

  def update
    @partner_lcy_rate = PartnerLcyRate.unscoped.find_by_id(params[:id])
    @partner_lcy_rate.attributes = params[:partner_lcy_rate]
    if !@partner_lcy_rate.valid?
      render "edit"
    else
      @partner_lcy_rate.updated_by = current_user.id
      @partner_lcy_rate.save!
      flash[:alert] = 'Partner Lcy Rate successfully modified and is pending for approval'
      redirect_to @partner_lcy_rate
    end
    rescue ActiveRecord::StaleObjectError
      @partner_lcy_rate.reload
      flash[:alert] = 'Someone edited the partner_lcy_rate the same time you did. Please re-apply your changes to the partner_lcy_rate.'
      render "edit"
  end 

  def update_lcy_for_mtss
    puts "---------- Update LCY rate"
    begin
    ######## IDP CALL ###########################

    username = PartnerLcyRate.read_username
    password = PartnerLcyRate.read_password

    api_url = ENV['LCY_RATE_URL']
    puts "-----------------lcy url #{api_url}"

    uri = URI("#{api_url}")

      headers  = {"X-IBM-Client-ID" => "#{ENV["IBM_CLIENT"]}","X-IBM-Client-Secret" => "#{ENV["CLIENT_SECRET"]}"}
      puts "---------lcy headers #{headers}"

      Net::HTTP.start(uri.host,uri.port,:use_ssl => uri.scheme == 'https',:verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        api_request = Net::HTTP::Post.new(uri.request_uri,headers)
        api_request.basic_auth "#{username}","#{password}"
        #api_request.body = {}.to_json
        api_request["accept-encoding"] = "identity"
        api_response = http.request api_request 

        
        #parse_json_res = JSON.parse(api_response.body) if api_response !=nil
        puts "---------------------lcy rate response ---#{api_response}"
        if (api_response.code == "200" && api_response !=nil)
          @text = "Rate Updated Successfully"
        else
          @text = "Service Failed Rate not updated"
        end  
      end

    rescue Exception => e
      puts "Exception during LCY rate update IDP API call ---#{e.inspect}"
      return @text = e
    end

    ############# IHS CALL #####################
    # begin
    #   mtss_url = PartnerLcyRate.mtss_url
    #   username = PartnerLcyRate.read_username
    #   password = PartnerLcyRate.read_password
        
    #   uri = URI("#{mtss_url}")
    #   Net::HTTP.start(uri.host, uri.port,
    #                   :use_ssl => uri.scheme == 'https',
    #                   :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
    #                   request = Net::HTTP::Post.new uri.request_uri
    #                   request.basic_auth "#{username}", "#{password}"
    #                   request.body = {}.to_json
    #                   @response = http.request request # Net::HTTPResponse object
    #                   end
    #                   if @response.code == "200"
    #                     @text = "Rate Updated Successfully"
    #                   else
    #                     @text = "Service Failed Rate not updated"
    #                   end
  # rescue Exception => e
  #    @text = e.to_s
  # end
  end

  def show
    @partner_lcy_rate = PartnerLcyRate.unscoped.find_by_id(params[:id])
  end

  # def index
  #   if request.get?
  #     @searcher = PartnerLcyRateSearcher.new(params.permit(:page, :approval_status))
  #   else
  #     @searcher = PartnerLcyRateSearcher.new(search_params)
  #   end
  #   @records = @searcher.paginate
  # end

  def index
    if params[:advanced_search].present?
      partner_lcy_rates = find_partner_lcy_rates(params).order("id DESC")
    else
      partner_lcy_rates = (params[:approval_status].present? and params[:approval_status] == 'U') ? PartnerLcyRate.unscoped.where("approval_status =?",'U').order("id desc") : PartnerLcyRate.order("id desc")
    end
    @partner_lcy_rates = partner_lcy_rates.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @partner_lcy_rate = PartnerLcyRate.unscoped.find(params[:id]) rescue nil
    @audit = @partner_lcy_rate.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  def tokenize_data_proc
    puts "before pk_ybl_tokenisation----------"
    begin
      result = plsql.pk_ybl_tokenisation.initiate_rules_tokenisation()
    rescue Exception => e
      puts "pk_ybl_tokenisation error #{e}"
    end
    
  end


  private    
    def search_params
      params.require(:partner_lcy_rate_searcher).permit( :page, :approval_status, :partner_code)
    end 


  def partner_lcy_rate_params
    params.require(:partner_lcy_rate).permit(:partner_code, :created_by, :updated_by, :approved_id, :approved_version, 
                                             :created_at, :updated_at, :lock_version, :rate, :approval_status)
  end
end