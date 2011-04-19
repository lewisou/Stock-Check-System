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
  
  def get_count_assigns symbol
    assigns = []
    curr_check.send("#{symbol.to_s}s".to_sym).each do |obj|
      if params[:count][obj.id.to_s].to_i > 0 && params[:count][obj.id.to_s].to_i < 3
        assigns << Assign.new(:count => params[:count][obj.id.to_s], symbol => obj)
      end
    end
    assigns
  end
end
