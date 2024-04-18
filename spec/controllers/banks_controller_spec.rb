require 'spec_helper'
require "cancan_matcher"

describe BanksController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all banks as @banks" do
      bank = Factory(:bank, :approval_status => 'A')
      get :index
      assigns(:banks).should eq([bank])
    end
    it "assigns all unapproved banks as @banks when approval_status is passed" do
      bank = Factory(:bank, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:banks).should eq([bank])
    end
  end

  describe "GET show" do
    it "assigns the requested bank as @bank" do
      bank = Factory(:bank)
      get :show, {:id => bank.id}
      assigns(:bank).should eq(bank)
    end
  end

  describe "GET new" do
    it "assigns a new bank as @bank" do
      get :new
      assigns(:bank).should be_a_new(Bank)
    end
  end

  describe "GET edit" do
    it "assigns the requested bank as @bank" do
      bank = Factory(:bank)
      get :edit, {:id => bank.id}
      assigns(:bank).should eq(bank)
    end
    
    it "assigns the requested bank with status 'A' as @bank" do
      bank = Factory(:bank,:approval_status => 'A')
      get :edit, {:id => bank.id}
      assigns(:bank).should eq(bank)
    end

    it "assigns the new bank with requested bank params when status 'A' as @bank" do
      bank = Factory(:bank,:approval_status => 'A')
      params = (bank.attributes).merge({:approved_id => bank.id,:approved_version => bank.lock_version})
      get :edit, {:id => bank.id}
      assigns(:bank).should eq(Bank.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new bank" do
        params = Factory.attributes_for(:bank)
        expect {
          post :create, {:bank => params}
        }.to change(Bank.unscoped, :count).by(1)
        flash[:alert].should  match(/Bank successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created bank as @bank" do
        params = Factory.attributes_for(:bank)
        post :create, {:bank => params}
        assigns(:bank).should be_a(Bank)
        assigns(:bank).should be_persisted
      end

      it "redirects to the created bank" do
        params = Factory.attributes_for(:bank)
        post :create, {:bank => params}
        response.should redirect_to(Bank.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bank as @bank" do
        params = Factory.attributes_for(:bank)
        params[:name] = nil
        expect {
          post :create, {:bank => params}
        }.to change(Bank, :count).by(0)
        assigns(:bank).should be_a(Bank)
        assigns(:bank).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:bank)
        params[:name] = nil
        post :create, {:bank => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested bank" do
        bank = Factory(:bank, :name => "abcd")
        params = bank.attributes.slice(*bank.class.attribute_names)
        params[:name] = "bank"
        put :update, {:id => bank.id, :bank => params}
        bank.reload
        bank.name.should == "bank"
      end

      it "assigns the requested bank as @bank" do
        bank = Factory(:bank, :name => "abcd")
        params = bank.attributes.slice(*bank.class.attribute_names)
        params[:name] = "15"
        put :update, {:id => bank.to_param, :bank => params}
        assigns(:bank).should eq(bank)
      end

      it "redirects to the bank" do
        bank = Factory(:bank, :name => "abcd")
        params = bank.attributes.slice(*bank.class.attribute_names)
        params[:name] = "bank"
        put :update, {:id => bank.to_param, :bank => params}
        response.should redirect_to(bank)
      end

      it "should raise error when tried to update at same time by many" do
        bank = Factory(:bank, :name => "abcd")
        params = bank.attributes.slice(*bank.class.attribute_names)
        params[:name] = "bank"
        bank2 = bank
        put :update, {:id => bank.id, :bank => params}
        bank.reload
        bank.name.should == "bank"
        params[:name] = "bcd"
        put :update, {:id => bank2.id, :bank => params}
        bank.reload
        bank.name.should == "bank"
        flash[:alert].should  match(/Someone edited the bank the same time you did. Please re-apply your changes to the bank/)
      end
    end

    describe "with invalid params" do
      it "assigns the bank as @bank" do
        bank = Factory(:bank, :name => "abcd")
        params = bank.attributes.slice(*bank.class.attribute_names)
        params[:name] = nil
        put :update, {:id => bank.to_param, :bank => params}
        assigns(:bank).should eq(bank)
        bank.reload
        params[:name] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        bank = Factory(:bank)
        params = bank.attributes.slice(*bank.class.attribute_names)
        params[:name] = nil
        put :update, {:id => bank.id, :bank => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested bank as @bank" do
      bank = Factory(:bank)
      get :audit_logs, {:id => bank.id, :version_id => 0}
      assigns(:bank).should eq(bank)
      assigns(:audit).should eq(bank.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:bank).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      bank1 = Factory(:bank, :approval_status => 'A')
      bank2 = Factory(:bank, :approval_status => 'U', :name => 'Bar Foo', :approved_version => bank1.lock_version, :approved_id => bank1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      bank1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(bank2.id).should_not be_nil
      put :approve, {:id => bank2.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(bank2.id).should be_nil
      bank1.reload
      bank1.name.should == 'Bar Foo'
      bank1.updated_by.should == "666"
      Bank.find_by_id(bank2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      bank = Factory(:bank, :name => 'Bar Foo', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(bank.id).should_not be_nil
      put :approve, {:id => bank.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(bank.id).should be_nil
      bank.reload
      bank.name.should == 'Bar Foo'
      bank.approval_status.should == 'A'
    end

  end
end