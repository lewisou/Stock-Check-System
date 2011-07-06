class God::ChecksController < God::BaseController
  layout :choose_lay

  before_filter do
    if ["current", "new"].include?(params["action"])
      @nav = :control
    else
      @nav = :archive
    end
  end

  # Status page
  def current
    if Check.curr_s.where(:state => 'init').count > 0
      redirect_to new_god_check_path(:step => 2)
      return
    end

    @check = Check.opt_s.first
  end

  # Create New Check
  before_filter :only => [:new, :create] do
    @step = (params[:step] || 1).to_i
  end
  def new
    @check = @step == 1 ? Check.new : Check.curr_s.first
    render "new_#{@step}"
  end

  def create
    if send "create_step_#{@step}"
      if @step < 2
        redirect_to new_god_check_path(:step => (@step + 1))
      else
        redirect_to edit_god_check_path(curr_check), :notice => "Check created. Please setup the check."
      end
    else
      render "new_#{@step}"
    end
  end

  # Setting page
  def edit
    @check = curr_check
  end

  # Setting page
  def update
    if curr_check.update_attributes(params[:check])
      redirect_to edit_god_check_path(curr_check.reload), :notice => "Basic Setting updated."
    else
      render :edit
    end
  end

  def change_state
    curr_check.state = params[:state]
    curr_check.generate_xls if curr_check.state == 'complete'
    curr_check.archive! if curr_check.state == 'archive'

    if curr_check.save
      redirect_to current_god_checks_path, :notice => "CURREN CHECK has been changed to #{params[:state]}."
    else
      redirect_to current_god_checks_path, :notice => "Failed change to #{params[:state]}."
    end
  end

  def history
    @checks = Check.history.paginate(:page => params[:page])
  end

  private
  def create_step_1
    @check = Check.new(params[:check])
    @check.save && @check.make_current! && @check.refresh_location
  end

  def create_step_2
    @check = Check.curr_s.first
    
    @check.set_remotes(params["remote_ids"])
    
    @check.refresh_item_and_group && @check.refresh_inventories && @check.reload.update_attributes(:state => "open", :admin => current_admin) && @check.generate!
  end
  
  def choose_lay
    params[:action] == 'edit' ? 'settings' : 'application'
  end

end