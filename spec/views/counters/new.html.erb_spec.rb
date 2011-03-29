require 'spec_helper'

describe "counters/new.html.erb" do
  before(:each) do
    assign(:counter, stub_model(Counter,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new counter form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => counters_path, :method => "post" do
      assert_select "input#counter_name", :name => "counter[name]"
    end
  end
end
