class AccountsController < God::BaseController
  layout 'settings'
  
  before_filter do
    @sub_menu = :account
  end
  
  def index
    @admins = Admin.paginate(:page => params[:page])
  end


  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(params[:admin])

    @admin.role_ids = params[:admin][:role_ids]
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

    params[:admin].delete(:password) if params[:admin][:password].blank?
    params[:admin].delete(:password_confirmation) if params[:admin][:password_confirmation].blank?

    @admin.role_ids = params[:admin][:role_ids]
    if @admin.update_attributes(params[:admin])
      redirect_to accounts_path, :notice => "Account #{@admin.username} has been successfully updated."
    else
      render :edit
    end
  end
  
  def destroy
    @admin = Admin.find(params[:id])
    
    if @admin.destroy
      redirect_to accounts_path, :notice => "Account deleted."
    else
      redirect_to accounts_path, :error => "Failed to delete."
    end
  end

end
