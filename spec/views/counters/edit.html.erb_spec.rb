require 'spec_helper'

describe "counters/edit.html.erb" do
  before(:each) do
    @counter = assign(:counter, stub_model(Counter,
      :name => "MyString"
    ))
  end

  it "renders the edit counter form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => counters_path(@counter), :method => "post" do
      assert_select "input#counter_name", :name => "counter[name]"
    end
  end
end
