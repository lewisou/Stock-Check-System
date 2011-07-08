class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_admin!

  after_filter :setup_menu
  def setup_menu
    @sub_menu = params[:sub_menu].to_sym unless params[:sub_menu].blank?
    @nav = params[:nav].to_sym unless params[:nav].blank?
  end

  around_filter :log_activities
  def log_activities
    
    if request.method.to_s != "GET"
      scope = admin_signed_in? ? current_admin.activities : Activity
      act_log = scope.create(:request => get_all_string_values(params).to_json, :finish => false, :met => request.method, :check => curr_check)
    end
    
    yield
    
    if request.method.to_s != "GET"
      act_log.update_attributes(:response => response.status.to_s, :ended_at => Time.now, :finish => true)
    end
  end

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
  
  private
  def rm_values rs
    rs.delete('authenticity_token')
    rs.delete("utf8")
    rs.delete_if {|key, value| !(key.to_s =~ /.*password.*/).nil? }
    
    rs.each do |key, value|
      case value
      when Hash
        rm_values value
      end
    end
    rs
  end
  
  def get_all_string_values hash
    return {} unless hash

    rs = {}
    hash.each do |key, value|
      case value
      when String
        rs[key] = value
      when Hash
        rs[key] = get_all_string_values(value)
      when Array
        rs[key] = value
      else
        rs[key] = "Object"
      end
    end

    rm_values(rs)
  end
  
end
