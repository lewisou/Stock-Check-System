class ApplicationController < ActionController::Base
  protect_from_forgery


  before_filter :authenticate_admin!

  helper_method :has_curr_check?
  def has_curr_check?
    return Check.opt_s.size > 0
  end
  
  helper_method :curr_check
  def curr_check
    unless @curr_check
      @curr_check = Check.opt_s.first
    end

    @curr_check
  end
  
  helper_method :has_role?
  def has_role? role
    return false unless current_admin
    
    case role
    when Symbol
      return current_admin.roles.map(&:code).include?(role.to_s)
    when Array
      role.each {|r| return true if current_admin.roles.map(&:code).include?(r.to_s)}
    else
      return false
    end
    return false
  end
  
  def check_role role
    if current_admin && !has_role?(role)
      render :text => "<h1>403 Forbidden</h1>", :status => 403
    end
  end

  helper_method :allow_data_entry?
  def allow_data_entry?
    return curr_check && curr_check.state == "open" && !has_role?(:mgt)
  end
  
  helper_method :allow_check_control?
  def allow_check_control?
    return (curr_check.nil? || ["complete", "cancel", "open"].include?(curr_check.state)) && !has_role?(:mgt)
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
