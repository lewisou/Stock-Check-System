require 'spec_helper'

describe "tags/edit.html.erb" do
  before(:each) do
    @tag = assign(:tag, stub_model(Tag,
      :count_1 => 1,
      :count_2 => 1,
      :count_3 => 1
    ))
  end

  it "renders the edit tag form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tags_path(@tag), :method => "post" do
      assert_select "input#tag_count_1", :name => "tag[count_1]"
      assert_select "input#tag_count_2", :name => "tag[count_2]"
      assert_select "input#tag_count_3", :name => "tag[count_3]"
    end
  end
end
