class CartsController < ApplicationController
  before_action :require_user!

  def show
    @cart = current_user.cart!
    authorize @cart
    @items = @cart.cart_items.includes(:course)
  end

  def apply_coupon
    cart = current_user.cart!
    authorize cart

    if cart.cart_items.empty?
      redirect_to cart_path, alert: "Košík je prázdný."
      return
    end

    result = CouponService.new(cart).apply(params[:coupon_code])
    if result.success?
      redirect_to cart_path, notice: "Slevový kód byl použit."
    else
      redirect_to cart_path, alert: result.error
    end
  end

  def remove_coupon
    cart = current_user.cart!
    authorize cart
    CouponService.new(cart).remove
    redirect_to cart_path, notice: "Slevový kód byl odebrán."
  end
end
