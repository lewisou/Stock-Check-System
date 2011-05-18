class Audit::BaseController < ApplicationController
  before_filter {check_role [:audit, :mgt]}
end