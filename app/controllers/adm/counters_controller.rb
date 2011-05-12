class Adm::CountersController < Adm::BaseController
  layout "tags"

  before_filter do
    @sub_menu = :counters
  end
  # GET /counters
  # GET /counters.xml
  def index
    @counters = Counter.order("name ASC").all
  end

  # GET /counters/1
  # GET /counters/1.xml
  def show
    @counter = Counter.find(params[:id])
  end

  # GET /counters/new
  # GET /counters/new.xml
  def new
    @counter = Counter.new
  end

  # GET /counters/1/edit
  def edit
    @counter = Counter.find(params[:id])
  end

  # POST /counters
  # POST /counters.xml
  def create
    @counter = Counter.new(params[:counter])

    @counter.new_assigns, @counter.curr_check = get_count_assigns(:location), curr_check
    respond_to do |format|
      if @counter.save
        format.html { redirect_to(adm_counters_path, :notice => 'Counter was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /counters/1
  # PUT /counters/1.xml
  def update
    @counter = Counter.find(params[:id])

    @counter.new_assigns, @counter.curr_check = get_count_assigns(:location), curr_check

    respond_to do |format|
      if @counter.update_attributes(params[:counter])
        format.html { redirect_to(adm_counters_path, :notice => 'Counter was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /counters/1
  # DELETE /counters/1.xml
  def destroy
    @counter = Counter.find(params[:id])
    @counter.destroy

    respond_to do |format|
      format.html { redirect_to(adm_counters_path) }
    end
  end
end
