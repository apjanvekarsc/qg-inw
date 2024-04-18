require 'spec_helper'
require "cancan_matcher"

describe PurposeCodesController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all purpose_codes as @records" do
      purpose_code = Factory(:purpose_code, :approval_status => 'A')
      get :index
      assigns(:records).should eq([purpose_code])
    end
    it "assigns all unapproved purpose_codes as @records when approval_status is passed" do
      purpose_code = Factory(:purpose_code, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([purpose_code])
    end
  end

  describe "GET show" do
    it "assigns the requested purpose_code as @purpose_code" do
      purpose_code = Factory(:purpose_code)
      get :show, {:id => purpose_code.id}
      assigns(:purpose_code).should eq(purpose_code)
    end
  end

  describe "GET new" do
    it "assigns a new purpose_code as @purpose_code" do
      get :new
      assigns(:purpose_code).should be_a_new(PurposeCode)
    end
  end

  describe "GET edit" do
    it "assigns the requested purpose_code as @purpose_code" do
      purpose_code = Factory(:purpose_code)
      get :edit, {:id => purpose_code.id}
      assigns(:purpose_code).should eq(purpose_code)
    end
    
    it "assigns the requested purpose_code with status 'A' as @purpose_code" do
      purpose_code = Factory(:purpose_code,:approval_status => 'A')
      get :edit, {:id => purpose_code.id}
      assigns(:purpose_code).should eq(purpose_code)
    end

    it "assigns the new partner with requested purpose_code params when status 'A' as @purpose_code" do
      purpose_code = Factory(:purpose_code,:approval_status => 'A')
      params = (purpose_code.attributes).merge({:approved_id => purpose_code.id,:approved_version => purpose_code.lock_version})
      get :edit, {:id => purpose_code.id}
      assigns(:purpose_code).should eq(PurposeCode.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new purpose_code" do
        params = Factory.attributes_for(:purpose_code)
        expect {
          post :create, {:purpose_code => params}
        }.to change(PurposeCode.unscoped, :count).by(1)
        flash[:alert].should  match(/Purpose Code successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created purpose_code as @purpose_code" do
        params = Factory.attributes_for(:purpose_code)
        post :create, {:purpose_code => params}
        assigns(:purpose_code).should be_a(PurposeCode)
        assigns(:purpose_code).should be_persisted
      end

      it "redirects to the created purpose_code" do
        params = Factory.attributes_for(:purpose_code)
        post :create, {:purpose_code => params}
        response.should redirect_to(PurposeCode.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved purpose_code as @purpose_code" do
        params = Factory.attributes_for(:purpose_code)
        params[:code] = nil
        expect {
          post :create, {:purpose_code => params}
        }.to change(PurposeCode, :count).by(0)
        assigns(:purpose_code).should be_a(PurposeCode)
        assigns(:purpose_code).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:purpose_code)
        params[:code] = nil
        post :create, {:purpose_code => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested purpose_code" do
        purpose_code = Factory(:purpose_code, :code => "PC11")
        params = purpose_code.attributes.slice(*purpose_code.class.attribute_names)
        params[:code] = "PC55"
        put :update, {:id => purpose_code.id, :purpose_code => params}
        purpose_code.reload
        purpose_code.code.should == "PC55"
      end

      it "assigns the requested purpose_code as @purpose_code" do
        purpose_code = Factory(:purpose_code, :code => "PC11")
        params = purpose_code.attributes.slice(*purpose_code.class.attribute_names)
        params[:code] = "PC55"
        put :update, {:id => purpose_code.to_param, :purpose_code => params}
        assigns(:purpose_code).should eq(purpose_code)
      end

      it "redirects to the purpose_code" do
        purpose_code = Factory(:purpose_code, :code => "PC11")
        params = purpose_code.attributes.slice(*purpose_code.class.attribute_names)
        params[:code] = "PC55"
        put :update, {:id => purpose_code.to_param, :purpose_code => params}
        response.should redirect_to(purpose_code)
      end

      it "should raise error when tried to update at same time by many" do
        purpose_code = Factory(:purpose_code, :code => "PC11")
        params = purpose_code.attributes.slice(*purpose_code.class.attribute_names)
        params[:code] = "PC55"
        purpose_code2 = purpose_code
        put :update, {:id => purpose_code.id, :purpose_code => params}
        purpose_code.reload
        purpose_code.code.should == "PC55"
        params[:code] = "PC88"
        put :update, {:id => purpose_code2.id, :purpose_code => params}
        purpose_code.reload
        purpose_code.code.should == "PC55"
        flash[:alert].should  match(/Someone edited the purpose_code the same time you did. Please re-apply your changes to the purpose_code/)
      end
    end

    describe "with invalid params" do
      it "assigns the purpose_code as @purpose_code" do
        purpose_code = Factory(:purpose_code, :code => "PC11")
        params = purpose_code.attributes.slice(*purpose_code.class.attribute_names)
        params[:code] = nil
        put :update, {:id => purpose_code.to_param, :purpose_code => params}
        assigns(:purpose_code).should eq(purpose_code)
        purpose_code.reload
        params[:code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        purpose_code = Factory(:purpose_code)
        params = purpose_code.attributes.slice(*purpose_code.class.attribute_names)
        params[:code] = nil
        put :update, {:id => purpose_code.id, :purpose_code => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested purpose_code as @purpose_code" do
      purpose_code = Factory(:purpose_code)
      get :audit_logs, {:id => purpose_code.id, :version_id => 0}
      assigns(:purpose_code).should eq(purpose_code)
      assigns(:audit).should eq(purpose_code.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:purpose_code).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      purpose_code1 = Factory(:purpose_code, :approval_status => 'A')
      purpose_code2 = Factory(:purpose_code, :description => 'BarFoo', :approval_status => 'U', :approved_version => purpose_code1.lock_version, :approved_id => purpose_code1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      purpose_code1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(purpose_code2.id).should_not be_nil
      put :approve, {:id => purpose_code2.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(purpose_code2.id).should be_nil
      purpose_code1.reload
      purpose_code1.description.should == 'BarFoo'
      purpose_code1.updated_by.should == "666"
      PurposeCode.find_by_id(purpose_code2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      purpose_code = Factory(:purpose_code, :description => 'BarFoo', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(purpose_code.id).should_not be_nil
      put :approve, {:id => purpose_code.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(purpose_code.id).should be_nil
      purpose_code.reload
      purpose_code.description.should == 'BarFoo'
      purpose_code.approval_status.should == 'A'
    end

  end
  
end