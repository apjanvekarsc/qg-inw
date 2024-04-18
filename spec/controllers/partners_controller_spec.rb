require 'spec_helper'
require "cancan_matcher"

describe PartnersController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
    
    mock_ldap
  end

  describe "GET index" do
    it "assigns all partners as @records" do
      partner = Factory(:partner, :approval_status => 'A')
      get :index
      assigns(:records).should eq([partner])
    end
    it "assigns all unapproved partners as @records when approval_status is passed" do
      partner = Factory(:partner, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([partner])
    end
  end

  describe "GET show" do
    it "assigns the requested partner as @partner" do
      partner = Factory(:partner)
      get :show, {:id => partner.id}
      assigns(:partner).should eq(partner)
    end
  end

  describe "GET new" do
    it "assigns a new partner as @partner" do
      get :new
      assigns(:partner).should be_a_new(Partner)
    end
  end

  describe "GET edit" do
    it "assigns the requested partner as @partner" do
      partner = Factory(:partner)
      get :edit, {:id => partner.id}
      assigns(:partner).should eq(partner)
    end
    
    it "assigns the requested partner with status 'A' as @partner" do
      partner = Factory(:partner,:approval_status => 'A')
      get :edit, {:id => partner.id}
      assigns(:partner).should eq(partner)
    end

    it "assigns the new partner with requested partner params when status 'A' as @partner" do
      partner = Factory(:partner,:approval_status => 'A')
      params = (partner.attributes).merge({:approved_id => partner.id,:approved_version => partner.lock_version})
      get :edit, {:id => partner.id}
      assigns(:partner).should eq(Partner.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new partner" do
        params = Factory.attributes_for(:partner)
        expect {
          post :create, {:partner => params}
        }.to change(Partner.unscoped, :count).by(1)
        flash[:alert].should  match(/Partner successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created partner as @partner" do
        params = Factory.attributes_for(:partner)
        post :create, {:partner => params}
        assigns(:partner).should be_a(Partner)
        assigns(:partner).should be_persisted
      end

      it "redirects to the created partner" do
        params = Factory.attributes_for(:partner)
        post :create, {:partner => params}
        response.should redirect_to(Partner.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved partner as @partner" do
        params = Factory.attributes_for(:partner)
        params[:code] = nil
        expect {
          post :create, {:partner => params}
        }.to change(Partner, :count).by(0)
        assigns(:partner).should be_a(Partner)
        assigns(:partner).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:partner)
        params[:code] = nil
        post :create, {:partner => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested partner" do
        partner = Factory(:partner, :code => "1111111111")
        params = partner.attributes.slice(*partner.class.attribute_names)
        params[:code] = "1555511111"
        put :update, {:id => partner.id, :partner => params}
        partner.reload
        partner.code.should == "1555511111"
      end

      it "assigns the requested partner as @partner" do
        partner = Factory(:partner, :code => "1111111111")
        params = partner.attributes.slice(*partner.class.attribute_names)
        params[:code] = "1555511111"
        put :update, {:id => partner.to_param, :partner => params}
        assigns(:partner).should eq(partner)
      end

      it "redirects to the partner" do
        partner = Factory(:partner, :code => "1111111111")
        params = partner.attributes.slice(*partner.class.attribute_names)
        params[:code] = "1555511111"
        put :update, {:id => partner.to_param, :partner => params}
        response.should redirect_to(partner)
      end

      it "should raise error when tried to update at same time by many" do
        partner = Factory(:partner, :code => "1111111111")
        params = partner.attributes.slice(*partner.class.attribute_names)
        params[:code] = "1555511111"
        partner2 = partner
        put :update, {:id => partner.id, :partner => params}
        partner.reload
        partner.code.should == "1555511111"
        params[:code] = "1888811111"
        put :update, {:id => partner2.id, :partner => params}
        partner.reload
        partner.code.should == "1555511111"
        flash[:alert].should  match(/Someone edited the partner the same time you did. Please re-apply your changes to the partner/)
      end
    end

    describe "with invalid params" do
      it "assigns the partner as @partner" do
        partner = Factory(:partner, :code => "1111111111")
        params = partner.attributes.slice(*partner.class.attribute_names)
        params[:code] = nil
        put :update, {:id => partner.to_param, :partner => params}
        assigns(:partner).should eq(partner)
        partner.reload
        params[:code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        partner = Factory(:partner)
        params = partner.attributes.slice(*partner.class.attribute_names)
        params[:code] = nil
        put :update, {:id => partner.id, :partner => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested partner as @partner" do
      partner = Factory(:partner)
      get :audit_logs, {:id => partner.id, :version_id => 0}
      assigns(:partner).should eq(partner)
      assigns(:audit).should eq(partner.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:partner).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      partner1 = Factory(:partner, :approval_status => 'A')
      partner2 = Factory(:partner, :name => 'BarFoo', :approval_status => 'U', :approved_version => partner1.lock_version, :approved_id => partner1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      partner1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(partner2.id).should_not be_nil
      put :approve, {:id => partner2.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(partner2.id).should be_nil
      partner1.reload
      partner1.updated_by.should == "666"
      Partner.find_by_id(partner2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      partner = Factory(:partner, :name => 'BarFoo', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(partner.id).should_not be_nil
      put :approve, {:id => partner.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(partner.id).should be_nil
      partner.reload
      partner.name.should == 'BarFoo'
      partner.approval_status.should == 'A'
    end

  end
  
end