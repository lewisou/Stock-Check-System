require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: activities
#
#  id          :integer         not null, primary key
#  admin_id    :integer
#  request     :text
#  response    :text
#  ended_at    :datetime
#  finish      :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#

