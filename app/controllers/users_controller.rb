class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)    # 実装は終わっていないことに注意!
    if @user.save
      #保存の成功をここで扱う
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user #redirect_to user_url(@user)というコードと等価
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 更新に成功した場合を扱う。
    else
      render 'edit'
    end
  end

  private

   def user_params
     params.require(:user).permit(:name,:email, :password,
                                   :password_confirmation)
   end
end
