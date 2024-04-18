require 'spec_helper'
require "cancan_matcher"

describe PartnerLcyRatesController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
    
    mock_ldap
  end

  describe "GET index" do
    it "assigns all partner_lcy_rates as @records" do
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'A')
      get :index
      assigns(:records).should eq([partner_lcy_rate])
    end
    it "assigns all unapproved partner_lcy_rates as @records when approval_status is passed" do
      partner_lcy_rate = Factory(:partner_lcy_rate, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([partner_lcy_rate])
    end
  end

  describe "GET show" do
    it "assigns the requested partner_lcy_rate as @partner_lcy_rate" do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      get :show, {:id => partner_lcy_rate.id}
      assigns(:partner_lcy_rate).should eq(partner_lcy_rate)
    end
  end


  describe "GET edit" do
    it "assigns the requested partner_lcy_rate as @partner_lcy_rate" do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      get :edit, {:id => partner_lcy_rate.id}
      assigns(:partner_lcy_rate).should eq(partner_lcy_rate)
    end
    
    it "assigns the requested partner_lcy_rate with status 'A' as @partner_lcy_rate" do
      partner_lcy_rate = Factory(:partner_lcy_rate,:approval_status => 'A')
      get :edit, {:id => partner_lcy_rate.id}
      assigns(:partner_lcy_rate).should eq(partner_lcy_rate)
    end

    it "assigns the new partner_lcy_rate with requested partner_lcy_rate params when status 'A' as @partner_lcy_rate" do
      partner_lcy_rate = Factory(:partner_lcy_rate,:approval_status => 'A')
      params = (partner_lcy_rate.attributes).merge({:approved_id => partner_lcy_rate.id,:approved_version => partner_lcy_rate.lock_version})
      get :edit, {:id => partner_lcy_rate.id}
      assigns(:partner_lcy_rate).should eq(PartnerLcyRate.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new partner_lcy_rate" do
        params = Factory.attributes_for(:partner_lcy_rate)
        expect {
          post :create, {:partner_lcy_rate => params}
        }.to change(PartnerLcyRate.unscoped, :count).by(1)
        flash[:alert].should  match(/Partner Lcy Rate successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created partner_lcy_rate as @partner_lcy_rate" do
        params = Factory.attributes_for(:partner_lcy_rate)
        post :create, {:partner_lcy_rate => params}
        assigns(:partner_lcy_rate).should be_a(PartnerLcyRate)
        assigns(:partner_lcy_rate).should be_persisted
      end

      it "redirects to the created partner_lcy_rate" do
        params = Factory.attributes_for(:partner_lcy_rate)
        post :create, {:partner_lcy_rate => params}
        response.should redirect_to(PartnerLcyRate.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved partner_lcy_rate as @partner_lcy_rate" do
        params = Factory.attributes_for(:partner_lcy_rate)
        params[:partner_code] = nil
        expect {
          post :create, {:partner_lcy_rate => params}
        }.to change(PartnerLcyRate, :count).by(0)
        assigns(:partner_lcy_rate).should be_a(PartnerLcyRate)
        assigns(:partner_lcy_rate).should_not be_persisted
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested partner_lcy_rate" do
        partner_lcy_rate = Factory(:partner_lcy_rate, :partner_code => "1111111111")
        params = partner_lcy_rate.attributes.slice(*partner_lcy_rate.class.attribute_names)
        params[:partner_code] = "1555511111"
        put :update, {:id => partner_lcy_rate.id, :partner_lcy_rate => params}
        partner_lcy_rate.reload
        partner_lcy_rate.partner_code.should == "1555511111"
      end

      it "assigns the requested partner_lcy_rate as @partner_lcy_rate" do
        partner_lcy_rate = Factory(:partner_lcy_rate, :partner_code => "1111111111")
        params = partner_lcy_rate.attributes.slice(*partner_lcy_rate.class.attribute_names)
        params[:partner_code] = "1555511111"
        put :update, {:id => partner_lcy_rate.to_param, :partner_lcy_rate => params}
        assigns(:partner_lcy_rate).should eq(partner_lcy_rate)
      end

      it "redirects to the partner_lcy_rate" do
        partner_lcy_rate = Factory(:partner_lcy_rate, :partner_code => "1111111111")
        params = partner_lcy_rate.attributes.slice(*partner_lcy_rate.class.attribute_names)
        params[:partner_code] = "1555511111"
        put :update, {:id => partner_lcy_rate.to_param, :partner_lcy_rate => params}
        response.should redirect_to(partner_lcy_rate)
      end

      it "should raise error when tried to update at same time by many" do
        partner_lcy_rate = Factory(:partner_lcy_rate, :partner_code => "1111111111")
        params = partner_lcy_rate.attributes.slice(*partner_lcy_rate.class.attribute_names)
        params[:partner_code] = "1555511111"
        partner_lcy_rate2 = partner_lcy_rate
        put :update, {:id => partner_lcy_rate.id, :partner_lcy_rate => params}
        partner_lcy_rate.reload
        partner_lcy_rate.partner_code.should == "1555511111"
        params[:partner_code] = "1888811111"
        put :update, {:id => partner_lcy_rate2.id, :partner_lcy_rate => params}
        partner_lcy_rate.reload
        partner_lcy_rate.partner_code.should == "1555511111"
        flash[:alert].should  match(/Someone edited the partner_lcy_rate the same time you did. Please re-apply your changes to the partner_lcy_rate/)
      end
    end

    describe "with invalid params" do
      it "assigns the partner_lcy_rate as @partner_lcy_rate" do
        partner_lcy_rate = Factory(:partner_lcy_rate, :partner_code => "1111111111")
        params = partner_lcy_rate.attributes.slice(*partner_lcy_rate.class.attribute_names)
        params[:partner_code] = nil
        put :update, {:id => partner_lcy_rate.to_param, :partner_lcy_rate => params}
        assigns(:partner_lcy_rate).should eq(partner_lcy_rate)
        partner_lcy_rate.reload
        params[:partner_code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        partner_lcy_rate = Factory(:partner_lcy_rate)
        params = partner_lcy_rate.attributes.slice(*partner_lcy_rate.class.attribute_names)
        params[:partner_code] = nil
        put :update, {:id => partner_lcy_rate.id, :partner_lcy_rate => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested partner_lcy_rate as @partner_lcy_rate" do
      partner_lcy_rate = Factory(:partner_lcy_rate)
      get :audit_logs, {:id => partner_lcy_rate.id, :version_id => 0}
      assigns(:partner_lcy_rate).should eq(partner_lcy_rate)
      assigns(:audit).should eq(partner_lcy_rate.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:partner_lcy_rate).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      partner_lcy_rate1 = Factory(:partner_lcy_rate, :approval_status => 'A')
      partner_lcy_rate2 = Factory(:partner_lcy_rate, :rate => 1, :approval_status => 'U', :approved_version => partner_lcy_rate1.lock_version, :approved_id => partner_lcy_rate1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      partner_lcy_rate1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(partner_lcy_rate2.id).should_not be_nil
      put :approve, {:id => partner_lcy_rate2.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(partner_lcy_rate2.id).should be_nil
      partner_lcy_rate1.reload
      partner_lcy_rate1.rate.should == 1
      partner_lcy_rate1.updated_by.should == "666"
      PartnerLcyRate.find_by_id(partner_lcy_rate2.id).should be_nil
    end
  end
  
end