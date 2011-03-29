class CountersController < ApplicationController
  # GET /counters
  # GET /counters.xml
  def index
    @counters = Counter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @counters }
    end
  end

  # GET /counters/1
  # GET /counters/1.xml
  def show
    @counter = Counter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @counter }
    end
  end

  # GET /counters/new
  # GET /counters/new.xml
  def new
    @counter = Counter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @counter }
    end
  end

  # GET /counters/1/edit
  def edit
    @counter = Counter.find(params[:id])
  end

  # POST /counters
  # POST /counters.xml
  def create
    @counter = Counter.new(params[:counter])

    respond_to do |format|
      if @counter.save
        format.html { redirect_to(@counter, :notice => 'Counter was successfully created.') }
        format.xml  { render :xml => @counter, :status => :created, :location => @counter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @counter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /counters/1
  # PUT /counters/1.xml
  def update
    @counter = Counter.find(params[:id])

    respond_to do |format|
      if @counter.update_attributes(params[:counter])
        format.html { redirect_to(@counter, :notice => 'Counter was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @counter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /counters/1
  # DELETE /counters/1.xml
  def destroy
    @counter = Counter.find(params[:id])
    @counter.destroy

    respond_to do |format|
      format.html { redirect_to(counters_url) }
      format.xml  { head :ok }
    end
  end
end
