class God::BaseController < ApplicationController
  before_filter {check_role [:controller, :mgt]}
end