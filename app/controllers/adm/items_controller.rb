class Adm::ItemsController < Adm::BaseController
  layout "tags"

  def new
    @item = curr_check.items.new
  end
  
  def edit
    @item = curr_check.items.find(params[:id])
  end
  
  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(params[:item])
      redirect_to missing_cost_adm_items_path(:sub_menu => :missing_cost), :notice => "Cost has been updated."
    else
      render :edit
    end
  end
  
  def create
    @item = curr_check.items.build(params[:item])
    @item.from_al = false
    
    if @item.save
      redirect_to adm_items_path, :notice => "Item #{@item.code} has been created."
    else
      render :new
    end
  end
  
  def show
    @item = curr_check.items.find(params[:id])
  end

  def index
    @search = curr_check.items.search(params[:search])
    @items = @search.paginate(:page => params[:page])
    
    if params[:search] && @search.count == 0
      @error_m = "Nothing found. <br />1.) Fix it now! Re-check the part number / item (Recommended) <br />2.) Fix it later. Create ticket (list for resolution with All Order)"
    end
  end

  def input_price
    @item = curr_check.items.find(params[:id])
  end

  def update_price
    @item = Item.find(params[:id])
    # @item = curr_check.items.find(params[:id])

    if @item.update_attributes(params[:item])
      redirect_to( missing_cost_adm_items_path, :notice => 'Cost was successfully updated.')
    else
      render :action => "input_price"
    end
  end

  def missing_cost
    @search = curr_check.items.missing_cost.search(params[:search])

    respond_to do |format|
      format.html { @items = @search.paginate(:page => params[:page]) }
      format.xls {
        @items = @search.all
        book = Spreadsheet::Workbook.new
        
        data = book.generate_xls(
        "Missing Cost", @items,        
        %w{ItemNumber Desc. Cost},
        [:code, :description, :cost]
        )

        send_data data, :filename => "Missing Cost.xls", :disposition => 'attachment'
      }
    end

  end
end