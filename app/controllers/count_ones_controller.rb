class CountOnesController < ApplicationController

  def missing_tag
    
  end

  def index
    @search = Tag.search
    
    if params[:search] && !params[:search][:id_eq].try(:blank?)
      @search = Tag.search(params[:search])

      if @search.count > 0
        @tag = @search.first
      end
    end
  end
  
  def edit
  end
  
  def update
  end
end
