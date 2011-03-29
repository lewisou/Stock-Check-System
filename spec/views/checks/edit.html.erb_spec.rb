require 'spec_helper'

describe "checks/edit.html.erb" do
  before(:each) do
    @check = assign(:check, stub_model(Check,
      :state => "MyString"
    ))
  end

  it "renders the edit check form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => checks_path(@check), :method => "post" do
      assert_select "input#check_state", :name => "check[state]"
    end
  end
end
