require "spec_helper"

describe CountersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/counters" }.should route_to(:controller => "counters", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/counters/new" }.should route_to(:controller => "counters", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/counters/1" }.should route_to(:controller => "counters", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/counters/1/edit" }.should route_to(:controller => "counters", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/counters" }.should route_to(:controller => "counters", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/counters/1" }.should route_to(:controller => "counters", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/counters/1" }.should route_to(:controller => "counters", :action => "destroy", :id => "1")
    end

  end
end
