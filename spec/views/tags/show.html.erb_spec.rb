require 'spec_helper'

describe "tags/show.html.erb" do
  before(:each) do
    @tag = assign(:tag, stub_model(Tag,
      :count_1 => 1,
      :count_2 => 1,
      :count_3 => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
