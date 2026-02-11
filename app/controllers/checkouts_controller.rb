class CheckoutsController < ApplicationController
  before_action :require_user!

  def billing
    cart = current_user.cart!
    authorize cart, :show?
    redirect_to cart_path, alert: "Košík je prázdný." and return if cart.cart_items.empty?

    @user = current_user
    @user.billing_name = @user.name if @user.billing_name.blank?
    @cart = cart
  end

  def create
    cart = current_user.cart!
    authorize cart, :show?

    @user = current_user
    @user.assign_attributes(billing_params) if billing_params.present?

    unless @user.save
      @cart = cart
      render :billing, status: :unprocessable_entity
      return
    end

    result = CheckoutService.new(
      user: current_user,
      cart: cart,
      billing_params: billing_params_for_order,
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url
    ).call

    if result.success?
      redirect_to result.redirect_url, allow_other_host: true
    else
      redirect_to cart_path, alert: result.error
    end
  end

  def success
    skip_authorization
  end

  def cancel
    skip_authorization
  end

  private

  def billing_params
    return {} unless params[:user]
    params.require(:user).permit(
      :billing_name, :billing_street, :billing_city, :billing_zip,
      :billing_country, :billing_ico, :billing_dic
    )
  end

  def billing_params_for_order
    {
      billing_name: current_user.billing_name,
      billing_street: current_user.billing_street,
      billing_city: current_user.billing_city,
      billing_zip: current_user.billing_zip,
      billing_country: current_user.billing_country,
      billing_ico: current_user.billing_ico,
      billing_dic: current_user.billing_dic
    }
  end
end
