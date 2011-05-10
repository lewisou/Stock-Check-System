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
  
  helper_method :has_role?
  def has_role? role
    return current_admin && current_admin.roles.map(&:code).include?(role.to_s)
  end
  
  def check_role role
    if current_admin && !has_role?(role)
      render :text => "<h1>403 Forbidden</h1>", :status => 403
    end
  end

  helper_method :allow_data_entry?
  def allow_data_entry?
    if curr_check && curr_check.state != "open"
      return false
    end
    true
  end

  def check_data_entry
    if !allow_data_entry?
      render :text => "<h1>403 Forbidden</h1>", :status => 403
    end
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
