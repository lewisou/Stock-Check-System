require 'spec_helper'

describe "checks/index.html.erb" do
  before(:each) do
    assign(:checks, [
      stub_model(Check,
        :state => "State"
      ),
      stub_model(Check,
        :state => "State"
      )
    ])
  end

  it "renders a list of checks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "State".to_s, :count => 2
  end
end
