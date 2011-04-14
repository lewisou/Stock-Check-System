class ChecksController < ApplicationController
  layout 'settings'
  
  before_filter { @sub_menu = :check }
  
  # GET /checks
  # GET /checks.xml
  def index
    @checks = Check.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checks }
    end
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
    if @check.save
      redirect_to(checks_path, :notice => 'Check was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /checks/1
  # PUT /checks/1.xml
  def update
    @check = Check.find(params[:id])

    respond_to do |format|
      if @check.update_attributes(params[:check])
        format.html { redirect_to(@check, :notice => 'Check was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @check.errors, :status => :unprocessable_entity }
      end
    end
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
      redirect_to checks_path, :notice => "CURREN CHECK has been changed to #{@check.description || @check.id}."
    else
      render index
    end
  end

  def change_state
    curr_check.state = params[:state]
    if curr_check.save
      redirect_to checks_path, :notice => "CURREN CHECK has been changed to #{params[:state]}."
    else
      render index
    end
  end  
end
