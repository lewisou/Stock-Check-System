class ChecksController < BaseController
  layout 'settings'
  
  # GET /checks
  # GET /checks.xml
  def index
    @checks = Check.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checks }
    end
  end

  def history
    @checks = Check.history.paginate(:page => params[:page])
  end

  # GET /checks/1
  # GET /checks/1.xml
  def show
    @check = Check.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @check }
    end
  end

  def current
    @check = Check.curr_s.first
  end

  # GET /checks/new
  # GET /checks/new.xml
  def new
    @check = Check.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @check }
    end
  end

  # GET /checks/1/edit
  def edit
    @check = Check.find(params[:id])
  end

  # POST /checks
  # POST /checks.xml
  def create
    @check = Check.new(params[:check])

    @check.admin = current_admin
    if @check.save && @check.make_current!
      redirect_to(current_checks_path, :notice => 'Check was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /checks/1
  # PUT /checks/1.xml
  # reimport
  def update
    @check = Check.find(params[:id])

    respond_to do |format|
      if @check.update_attributes(params[:check])
        format.html { redirect_to(current_checks_path, :notice => 'Reimport finished.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "reimport" }
        format.xml  { render :xml => @check.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reimport
    @check = curr_check
  end

  # DELETE /checks/1
  # DELETE /checks/1.xml
  def destroy
    @check = Check.find(params[:id])
    @check.destroy

    respond_to do |format|
      format.html { redirect_to(checks_url) }
      format.xml  { head :ok }
    end
  end

  def make_current
    @check = Check.find(params[:id])
    if @check.make_current!
      redirect_to current_checks_path, :notice => "CURREN CHECK has been changed to #{@check.description || @check.id}."
    else
      render index
    end
  end

  def change_state
    curr_check.state = params[:state]
    curr_check.generate_xls if curr_check.state == 'complete'

    if curr_check.save

      redirect_to current_checks_path, :notice => "CURREN CHECK has been changed to #{params[:state]}."
    else
      render index
    end
  end
  
  def refresh_count
    curr_check.cache_counted!
    
    redirect_to missing_cost_items_path, :notice => "Refresh finished."
  end

  def color
    @check = curr_check
  end
  
  def color_update
    if curr_check.update_attributes(params[:check])
      redirect_to color_checks_path, :notice => "Colors changed."
    else
      render :color
    end
  end

  def generate
    curr_check.generate!
    redirect_to current_checks_path, :notice => "Initial tags have been generated."
  end
  
  def to_generate
  end
  
  def instruction
    @check = curr_check
  end
  
  def upload_ins
    @check = curr_check
    
    @check.update_attributes(:instruction_file => params[:check][:instruction_file]) unless params[:check].blank? || params[:check][:instruction_file].blank?
    
    redirect_to instruction_checks_path, :notice => "OK"
  end

end
