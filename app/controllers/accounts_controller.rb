class AccountsController < ApplicationController
  layout 'settings'
  
  before_filter do
    @sub_menu = :account
  end
  
  def index
    @admins = Admin.all
  end
  
  
  def new
    @admin = Admin.new
  end
  
  def create
    @admin = Admin.new(params[:admin])
    
    if @admin.save
      redirect_to accounts_path, :notice => "Account #{@admin.username} has been successfully added."
    else
      render :new
    end
  end
  
  def edit
    @admin = Admin.find(params[:id])
  end
  
  def update
    @admin = Admin.find(params[:id])
    
    if @admin.update_attributes(params[:admin])
      redirect_to accounts_path, :notice => "Account #{@admin.username} has been successfully updated."
    else
      render :edit
    end
  end

end
