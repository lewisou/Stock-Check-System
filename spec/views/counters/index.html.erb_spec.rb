require 'spec_helper'

describe "counters/index.html.erb" do
  before(:each) do
    assign(:counters, [
      stub_model(Counter,
        :name => "Name"
      ),
      stub_model(Counter,
        :name => "Name"
      )
    ])
  end

  it "renders a list of counters" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
