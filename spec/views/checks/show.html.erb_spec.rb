require 'spec_helper'

describe "checks/show.html.erb" do
  before(:each) do
    @check = assign(:check, stub_model(Check,
      :state => "State"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/State/)
  end
end
