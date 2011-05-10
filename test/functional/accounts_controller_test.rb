require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index" do

    adm = Admin.create(:username => 'lewis', :email => 'lewis.zhou@vxmt.com.cn', :password => '123456', :password_confirmation => '123456')
    adm.roles << Role.create(:code => 'controller')
    adm.save
    
    sign_in adm

    get :index
    assert_response :success
  end

end
