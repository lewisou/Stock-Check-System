require "spec_helper"

describe ChecksController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/checks" }.should route_to(:controller => "checks", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/checks/new" }.should route_to(:controller => "checks", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/checks/1" }.should route_to(:controller => "checks", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/checks/1/edit" }.should route_to(:controller => "checks", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/checks" }.should route_to(:controller => "checks", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/checks/1" }.should route_to(:controller => "checks", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/checks/1" }.should route_to(:controller => "checks", :action => "destroy", :id => "1")
    end

  end
end
