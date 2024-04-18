require 'will_paginate/array'

class InwIdentitiesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper

end