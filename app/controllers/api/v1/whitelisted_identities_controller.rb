class Api::V1::WhitelistedIdentitiesController < ApplicationController
  before_action :restrict_access
  respond_to :xml

  def create
    string = request.body.read
    object = Hash.from_xml(string)
    params.merge!(object)
    @whitelisted_identity = WhitelistedIdentity.new(whitelisted_identity_params)
    if @whitelisted_identity.save
      render xml: @whitelisted_identity
    else
      render xml: @whitelisted_identity.errors
    end
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end

  def user_params
    {}
  end

  def whitelisted_identity_params
    params.require(:whitelisted_identity).permit(:created_by, :first_name, :first_used_with_txn_id, :full_name, :id_country, 
                                                 :id_issue_date, :id_expiry_date, :id_number, :id_type, :is_verified, :last_name, 
                                                 :last_used_with_txn_id, :lock_version, :partner_id, :times_used,
                                                 :updated_by, :verified_at, :verified_by, {:attachments_attributes => [:note, :user_id, :file, :_destroy]})
  end

end
