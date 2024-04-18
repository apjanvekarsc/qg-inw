require 'spec_helper'
require "cancan_matcher"

describe InwRemittanceRulesController do
  include HelperMethods

  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new inw_remittance_rule" do
        params = Factory.attributes_for(:inw_remittance_rule)
        expect {
          post :create, {:inw_remittance_rule => params}
        }.to change(InwRemittanceRule.unscoped, :count).by(1)
        flash[:alert].should  match(/Rule successfully created/)
        response.should be_redirect
      end

      it "assigns a newly created inw_remittance_rule as @rule" do
        params = Factory.attributes_for(:inw_remittance_rule)
        post :create, {:inw_remittance_rule => params}
        assigns(:inw_remittance_rule).should be_a(InwRemittanceRule)
        assigns(:inw_remittance_rule).should be_persisted
      end

      it "redirects to the created inw_remittance_rule" do
        params = Factory.attributes_for(:inw_remittance_rule)
        post :create, {:inw_remittance_rule => params}
        response.should redirect_to(InwRemittanceRule.unscoped.last)
      end
    end
  end

  describe "GET show" do
    it "assigns the requested inw_remittance_rule as @inw_remittance_rule" do
      inw_remittance_rule = Factory(:inw_remittance_rule)
      get :show, {:id => inw_remittance_rule.id}
      assigns(:inw_remittance_rule).should eq(inw_remittance_rule)
    end
  end

  describe "GET edit" do
    it "assigns the requested inw_remittance_rule as @inw_remittance_rule" do
      inw_remittance_rule = Factory(:inw_remittance_rule)
      get :edit, {:id => inw_remittance_rule.id}
      assigns(:inw_remittance_rule).should eq(inw_remittance_rule)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested rule" do
        rule = Factory(:inw_remittance_rule, :pattern_individuals => "11")
        params = rule.attributes.slice(*rule.class.attribute_names)
        params[:pattern_individuals] = "15"
        put :update, {:id => rule.id, :inw_remittance_rule => params}
        rule.reload
        rule.pattern_individuals.should == "15"
      end

      it "assigns the requested rule as @rule" do
        rule = Factory(:inw_remittance_rule, :pattern_individuals => "11")
        params = rule.attributes.slice(*rule.class.attribute_names)
        params[:pattern_individuals] = "15"
        put :update, {:id => rule.to_param, :inw_remittance_rule => params}
        assigns(:inw_remittance_rule).should eq(rule)
      end

      it "redirects to the rule" do
        rule = Factory(:inw_remittance_rule, :pattern_individuals => "11")
        params = rule.attributes.slice(*rule.class.attribute_names)
        params[:pattern_individuals] = "15"
        put :update, {:id => rule.to_param, :inw_remittance_rule => params}
        response.should redirect_to(rule)
      end

      it "should raise error when tried to update at same time by many" do
        rule = Factory(:inw_remittance_rule, :pattern_individuals => "11")
        params = rule.attributes.slice(*rule.class.attribute_names)
        params[:pattern_individuals] = "15"
        rule2 = rule
        put :update, {:id => rule.id, :inw_remittance_rule => params}
        rule.reload
        rule.pattern_individuals.should == "15"
        params[:pattern_individuals] = "18"
        put :update, {:id => rule2.id, :inw_remittance_rule => params}
        rule.reload
        rule.pattern_individuals.should == "15"
        flash[:alert].should  match(/Someone edited the rule the same time you did. Please re-apply your changes to the rule/)
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested rule as @rule" do
      rule = Factory(:inw_remittance_rule)
      get :audit_logs, {:id => rule.id, :version_id => 0}
      assigns(:rule).should eq(rule)
      assigns(:audit).should eq(rule.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:rule).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "GET error_msg" do
    it "displays the flash msg and redirects to root" do
      rule = Factory(:inw_remittance_rule)
      get :error_msg
      flash[:alert].should  match(/Rule is not yet configured/)      
      response.should redirect_to(:root)
    end
  end
  
  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      inw_remittance_rule1 = Factory(:inw_remittance_rule, :approval_status => 'A')
      inw_remittance_rule2 = Factory(:inw_remittance_rule, :approval_status => 'U', :pattern_individuals => '1234', :approved_version => inw_remittance_rule1.lock_version, :approved_id => inw_remittance_rule1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      inw_remittance_rule1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(inw_remittance_rule2.id).should_not be_nil
      put :approve, {:id => inw_remittance_rule2.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(inw_remittance_rule2.id).should be_nil
      inw_remittance_rule1.reload
      inw_remittance_rule1.pattern_individuals.should == '1234'
      inw_remittance_rule1.updated_by.should == "666"
      Bank.find_by_id(inw_remittance_rule2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      inw_remittance_rule = Factory(:inw_remittance_rule, :pattern_individuals => '1234', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      UnapprovedRecord.find_by_approvable_id(inw_remittance_rule.id).should_not be_nil
      put :approve, {:id => inw_remittance_rule.id}
      UnapprovedRecord.count.should == 0
      UnapprovedRecord.find_by_approvable_id(inw_remittance_rule.id).should be_nil
      inw_remittance_rule.reload
      inw_remittance_rule.pattern_individuals.should == '1234'
      inw_remittance_rule.approval_status.should == 'A'
    end

  end
  
end