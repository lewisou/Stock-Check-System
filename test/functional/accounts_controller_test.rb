require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index" do
    sign_in Admin.create(:username => 'lewis', :email => 'lewis.zhou@vxmt.com.cn', :password => '123456', :password_confirmation => '123456')
    
    get :index
    assert_response :success
  end

end
