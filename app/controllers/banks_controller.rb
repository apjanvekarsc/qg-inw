require 'will_paginate/array'

class BanksController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper

  def new
    @bank = Bank.new
  end

  def create
    @bank = Bank.new(params[:bank])
    if !@bank.valid?
      render "new"
    else
      @bank.created_by = current_user.id
      @bank.save!
      flash[:alert] = 'Bank successfully created and is pending for approval'
      redirect_to @bank
    end
  end

  def update
    @bank = Bank.unscoped.find_by_id(params[:id])
    @bank.attributes = params[:bank]
    if !@bank.valid?
      render "edit"
    else
      @bank.updated_by = current_user.id
      @bank.save!
      flash[:alert] = 'Bank successfully modified and is pending for approval'
      redirect_to @bank
    end
    rescue ActiveRecord::StaleObjectError
      @bank.reload
      flash[:alert] = 'Someone edited the bank the same time you did. Please re-apply your changes to the bank.'
      render "edit"
  end 

  def show
    @bank = Bank.unscoped.find_by_id(params[:id])
  end

  def index
    @banks ||= Bank.order("id desc").paginate(:per_page => 10, :page => params[:page])
    @banks_count = @banks.count
  end

  def audit_logs
    @bank = Bank.unscoped.find(params[:id]) rescue nil
    @audit = @bank.audits[params[:version_id].to_i] rescue nil
  end

  def approve
    redirect_to unapproved_records_path(group_name: 'inward-remittance')
  end

  private

  def bank_params
    params.require(:bank).permit(:ifsc,:name,:imps_enabled, :created_by, :updated_by, :lock_version,
                                 :approved_id, :approved_version)
  end
end
