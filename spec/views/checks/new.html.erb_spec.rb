require 'spec_helper'

describe "checks/new.html.erb" do
  before(:each) do
    assign(:check, stub_model(Check,
      :state => "MyString"
    ).as_new_record)
  end

  it "renders new check form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => checks_path, :method => "post" do
      assert_select "input#check_state", :name => "check[state]"
    end
  end
end
