class TagsController < ApplicationController

  # GET /tags
  # GET /tags.xml
  def index
    @search = Tag.search(params[:search])
    @tags = @search.paginate(:page => params[:page])
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @sub_menu = :add
    
    @inventory = Inventory.find(params[:inventory_id])
    @tag = @inventory.tags.build
    # render :layout => 'tags'
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    @inventory = Inventory.find(params[:inventory_id])
    @tag = @inventory.tags.build(params[:tag])

    respond_to do |format|
      if @tag.save
        format.html { redirect_to(@tag, :notice => 'Tag was successfully created.') }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to(@tag, :notice => 'Tag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

  def to_import
  end

  def import
    book = Spreadsheet.open params[:file].path
    sheet1 = book.worksheet 0

    sheet1.each_with_index do |row, index|
      @item = Item.find_by_code(row[0])
      unless @item
        if row[34].to_i == 1
          @item = Item.create :code => row[0], :description => row[1], :cost => row[20], :qb_id => row[75]
        end
      end
      
      if @item && @item.tags.size() == 0
        tag = @item.tags.create(:location_id => Location.first.id)
      end
      
      # puts "Item #{row[0]}"
      # puts "SalesDesc #{row[1]}"
      # puts "QuantityOnHand #{row[15]}"
      # puts "AverageCost #{row[20]}"
      # puts "IsActive #{row[34]}"
      # puts "ItemCust3 #{row[41]}"
      # break if index > 100
    end

    redirect_to to_import_tags_path
  end

end
