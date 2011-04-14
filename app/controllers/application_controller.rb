class ApplicationController < ActionController::Base
  protect_from_forgery


  before_filter :authenticate_admin!

  helper_method :has_curr_check?
  def has_curr_check?
    return Check.curr_s.size > 0
  end
  
  helper_method :curr_check
  def curr_check
    unless @curr_check
      @curr_check = Check.curr_s.first
    end

    @curr_check
  end
end
