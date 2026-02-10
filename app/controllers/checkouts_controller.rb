class CheckoutsController < ApplicationController
  before_action :require_user!

  def create
    cart = current_user.cart!
    authorize cart, :show?

    result = CheckoutService.new(
      user: current_user,
      cart: cart,
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
end
