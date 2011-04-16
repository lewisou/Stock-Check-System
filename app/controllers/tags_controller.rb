require 'ext/tag_table'

class TagsController < ApplicationController

  # GET /tags
  # GET /tags.xml
  def index
    @search = Tag.in_check(curr_check.id).includes(:inventory => :item, :inventory => :location).search(params[:search])

    respond_to do |format|
      format.html { @tags = @search.paginate(:page => params[:page]) }

      format.pdf {
        @tags = @search.all

        pdf = Prawn::Document.generate_tags @tags
        send_data pdf.render, :filename => "tags.pdf", :disposition => 'attachment'
      }
    end
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
    @tag = Tag.new

    if params[:inventory_id]
      inventory = Inventory.find(params[:inventory_id])
      @tag.item_id, @item = inventory.item.id, inventory.item
      @tag.location_id = inventory.location.id
    elsif params[:item_id]
      @tag.item_id, @item = params[:item_id].to_i, Item.find(params[:item_id])
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.in_check(curr_check.id).find(params[:id])
    @item = @tag.inventory.item
    @tag.item_id = @item.id
    @tag.location_id = @tag.inventory.location.id
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

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
    @tag = Tag.in_check(curr_check.id).find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

end
