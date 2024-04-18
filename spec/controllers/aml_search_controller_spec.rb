require 'spec_helper'
require 'webmock/rspec'
require "cancan_matcher"

describe AmlSearchController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"

    @result_body = "{\"hits\":{\"hit\":[{\"id\":\"735\",\"firstName\":\"nil\",\"lastName\":\"EMPRESA CUBANA DE AVIACION\",\"type\":\"Entity\",\"remarks\":\"nil\",\"identities\":{\"numIdentities\":\"0\",\"identity\":\"nil\"}, \"aliases\":{\"numAliases\":\"0\",\"alias\":\"nil\"}, \"addresses\":{\"numAddresses\":\"0\",\"address\":\"nil\"}}]}}" 
    stub_request(:get, ENV['CONFIG_URL_AML_SEARCH'] + "firstName=cubana").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => @result_body, :headers => {'Content-Type' => 'application/json'})
  end

  context 'get_response_from_api' do
    it "should return response from api" do 
      h = AmlSearchController.new
      h.get_response_from_api(ENV['CONFIG_URL_AML_SEARCH'] + "firstName=cubana").should == JSON.parse(@result_body)["hits"]["hit"]
    end
  end

  context 'search_params' do
    it "should return a string of key and value" do 
      h = AmlSearchController.new
      h.search_params({"firstName" => "cubana", "idNumber" => "1234"}).should == "firstName=cubana&idNumber=1234"
    end
  end

  context 'find_values' do
    it "should return [] if the num is 0" do 
      h = AmlSearchController.new
      h.find_values("0",[]).should == []
    end

    it "should return [] if the num is 1" do 
      h = AmlSearchController.new
      h.find_values("1","value").should == ["value"]
    end

    it "should return [] if the num is 0" do 
      h = AmlSearchController.new
      h.find_values("2",["value1","value2"]).should == ["value1","value2"]
    end
  end

  context "find_search_results" do 
    it "should return error if first name is empty" do
      get :find_search_results, :search_params => {:firstName => ""}
      flash[:alert].should  match(/Name should not be empty/)
    end

    it "should assign results to @results" do
      get :find_search_results, :search_params => {:firstName => "cubana"}
      response.should be_redirect
    end
  end

  context "results" do 
    it "should assign results to @results" do
      get :results, :search_params => {:firstName => "cubana"}
      assigns(:results).should == JSON.parse(@result_body)["hits"]["hit"]
      assigns(:search_params).should == "firstName=cubana"
    end
  end

  context "search_result" do 
    it "should assign result to @result" do
      get :search_result, :search_params => "firstName=cubana", :index => "0"
      assigns(:result).should == JSON.parse(@result_body)["hits"]["hit"][0]
      assigns(:identities).should == []
      assigns(:aliases).should == []
      assigns(:addresses).should == []
    end
  end
end
