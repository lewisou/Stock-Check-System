class Adm::BaseController < ApplicationController

  before_filter {check_role :admin}

end