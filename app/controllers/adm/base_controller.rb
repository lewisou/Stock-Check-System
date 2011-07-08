class Adm::BaseController < ApplicationController
  before_filter {check_role [:organizer, :controller, :mgt]}
end