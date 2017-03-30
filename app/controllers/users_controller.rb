class UsersController < ApplicationController

  def account
    @user = current_user
  end

end
