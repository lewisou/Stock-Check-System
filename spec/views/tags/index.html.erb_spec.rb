require 'spec_helper'

describe "tags/index.html.erb" do
  before(:each) do
    assign(:tags, [
      stub_model(Tag,
        :count_1 => 1,
        :count_2 => 1,
        :count_3 => 1
      ),
      stub_model(Tag,
        :count_1 => 1,
        :count_2 => 1,
        :count_3 => 1
      )
    ])
  end

  it "renders a list of tags" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
