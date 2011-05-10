class BaseController < ApplicationController
  before_filter {check_role :controller}
end