require 'spec_helper'
require "cancan_matcher"

describe InwGuidelinesController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all inw_guidelines as @inw_guidelines" do
      inw_guideline = Factory(:inw_guideline, :approval_status => 'A')
      get :index
      assigns(:inw_guidelines).should eq([inw_guideline])
    end
    it "assigns all unapproved inw_guidelines as @inw_guidelines when approval_status is passed" do
      inw_guideline = Factory(:inw_guideline, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:inw_guidelines).should eq([inw_guideline])
    end
  end

  describe "GET show" do
    it "assigns the requested inw_guideline as @inw_guideline" do
      inw_guideline = Factory(:inw_guideline)
      get :show, {:id => inw_guideline.id}
      assigns(:inw_guideline).should eq(inw_guideline)
    end
  end

  describe "GET edit" do
    it "assigns the requested inw_guideline as @inw_guideline" do
      inw_guideline = Factory(:inw_guideline)
      get :edit, {:id => inw_guideline.id}
      assigns(:inw_guideline).should eq(inw_guideline)
    end
    
    it "assigns the requested inw_guideline with status 'A' as @inw_guideline" do
      inw_guideline = Factory(:inw_guideline,:approval_status => 'A')
      get :edit, {:id => inw_guideline.id}
      assigns(:inw_guideline).should eq(inw_guideline)
    end

    it "assigns the new inw_guideline with requested inw_guideline params when status 'A' as @inw_guideline" do
      inw_guideline = Factory(:inw_guideline,:approval_status => 'A')
      params = (inw_guideline.attributes).merge({:approved_id => inw_guideline.id,:approved_version => inw_guideline.lock_version})
      get :edit, {:id => inw_guideline.id}
      assigns(:inw_guideline).should eq(InwGuideline.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new inw_guideline" do
        params = Factory.attributes_for(:inw_guideline)
        expect {
          post :create, {:inw_guideline => params}
        }.to change(InwGuideline.unscoped, :count).by(1)
        flash[:alert].should  match(/InwGuideline successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created inw_guideline as @inw_guideline" do
        params = Factory.attributes_for(:inw_guideline)
        post :create, {:inw_guideline => params}
        assigns(:inw_guideline).should be_a(InwGuideline)
        assigns(:inw_guideline).should be_persisted
      end

      it "redirects to the created inw_guideline" do
        params = Factory.attributes_for(:inw_guideline)
        post :create, {:inw_guideline => params}
        response.should redirect_to(InwGuideline.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved inw_guideline as @inw_guideline" do
        params = Factory.attributes_for(:inw_guideline)
        params[:allow_neft] = nil
        expect {
          post :create, {:inw_guideline => params}
        }.to change(InwGuideline, :count).by(0)
        assigns(:inw_guideline).should be_a(InwGuideline)
        assigns(:inw_guideline).should_not be_persisted
      end

      it "re-renders the 'edit' template when show_errors is true" do
        params = Factory.attributes_for(:inw_guideline)
        params[:allow_neft] = nil
        post :create, {:inw_guideline => params}
        response.should render_template("edit")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested inw_guideline" do
        inw_guideline = Factory(:inw_guideline, :code => "1111111111")
        params = inw_guideline.attributes.slice(*inw_guideline.class.attribute_names)
        params[:code] = "1555511111"
        put :update, {:id => inw_guideline.id, :inw_guideline => params}
        inw_guideline.reload
        inw_guideline.code.should == "1555511111"
      end

      it "assigns the requested inw_guideline as @inw_guideline" do
        inw_guideline = Factory(:inw_guideline, :code => "1111111111")
        params = inw_guideline.attributes.slice(*inw_guideline.class.attribute_names)
        params[:code] = "1555511111"
        put :update, {:id => inw_guideline.to_param, :inw_guideline => params}
        assigns(:inw_guideline).should eq(inw_guideline)
      end

      it "redirects to the inw_guideline" do
        inw_guideline = Factory(:inw_guideline, :code => "1111111111")
        params = inw_guideline.attributes.slice(*inw_guideline.class.attribute_names)
        params[:code] = "1555511111"
        put :update, {:id => inw_guideline.to_param, :inw_guideline => params}
        response.should redirect_to(inw_guideline)
      end

      it "should raise error when tried to update at same time by many" do
        inw_guideline = Factory(:inw_guideline, :code => "1111111111")
        params = inw_guideline.attributes.slice(*inw_guideline.class.attribute_names)
        params[:code] = "1555511111"
        inw_guideline2 = inw_guideline
        put :update, {:id => inw_guideline.id, :inw_guideline => params}
        inw_guideline.reload
        inw_guideline.code.should == "1555511111"
        params[:code] = "1888811111"
        put :update, {:id => inw_guideline2.id, :inw_guideline => params}
        inw_guideline.reload
        inw_guideline.code.should == "1555511111"
        flash[:alert].should  match(/Someone edited the inw_guideline the same time you did. Please re-apply your changes to the inw_guideline/)
      end
    end

    describe "with invalid params" do
      it "assigns the inw_guideline as @inw_guideline" do
        inw_guideline = Factory(:inw_guideline, :code => "1111111111")
        params = inw_guideline.attributes.slice(*inw_guideline.class.attribute_names)
        params[:allow_neft] = nil
        put :update, {:id => inw_guideline.to_param, :inw_guideline => params}
        assigns(:inw_guideline).should eq(inw_guideline)
        inw_guideline.reload
        params[:allow_neft] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        inw_guideline = Factory(:inw_guideline)
        params = inw_guideline.attributes.slice(*inw_guideline.class.attribute_names)
        params[:allow_neft] = nil
        put :update, {:id => inw_guideline.id, :inw_guideline => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested inw_guideline as @inw_guideline" do
      inw_guideline = Factory(:inw_guideline)
      get :audit_logs, {:id => inw_guideline.id, :version_id => 0}
      assigns(:inw_guideline).should eq(inw_guideline)
      assigns(:audit).should eq(inw_guideline.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:inw_guideline).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      inw_guideline1 = Factory(:inw_guideline, :approval_status => 'A')
      inw_guideline2 = Factory(:inw_guideline, :code => 'BarFoo', :approval_status => 'U', :approved_version => inw_guideline1.lock_version, :approved_id => inw_guideline1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      inw_guideline1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(inw_guideline2.id).should_not be_nil
      put :approve, {:id => inw_guideline2.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(inw_guideline2.id).should be_nil
      inw_guideline1.reload
      inw_guideline1.code.should == 'BarFoo'
      inw_guideline1.updated_by.should == "666"
      InwGuideline.find_by_id(inw_guideline2.id).should be_nil
    end
  end
  
end