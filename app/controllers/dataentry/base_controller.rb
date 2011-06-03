class Dataentry::BaseController < ApplicationController
  before_filter {check_role [:dataentry]}
end