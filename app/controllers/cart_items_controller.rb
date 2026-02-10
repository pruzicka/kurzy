class CartItemsController < ApplicationController
  before_action :require_user!

  def create
    authorize CartItem
    course = Course.publicly_visible.find(params[:course_id])
    current_user.cart!.add_course!(course, params[:quantity] || 1)
    redirect_to cart_path, notice: "Kurz byl přidán do košíku."
  rescue ArgumentError
    redirect_to cart_path, alert: "Košík může obsahovat jen jednu měnu."
  end

  def update
    item = current_user.cart!.cart_items.find(params[:id])
    authorize item
    quantity = params[:quantity].to_i
    if quantity <= 0
      item.destroy
    else
      item.update!(quantity: quantity)
    end
    redirect_to cart_path
  end

  def destroy
    item = current_user.cart!.cart_items.find(params[:id])
    authorize item
    item.destroy
    redirect_to cart_path, notice: "Kurz byl odebrán z košíku."
  end
end
