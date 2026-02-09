module AdminArea
  class OrdersController < BaseController
    def index
      @query = params[:q].to_s.strip
      scope = Order.includes(:user, :coupon).left_joins(:user)
      if @query.present?
        like = "%#{@query}%"
        adapter = ActiveRecord::Base.connection.adapter_name.downcase
        if adapter.include?("sqlite")
          scope = scope.where(
            "users.email LIKE :q OR users.first_name LIKE :q OR users.last_name LIKE :q OR CAST(orders.id AS TEXT) LIKE :q OR orders.status LIKE :q",
            q: like
          )
        else
          scope = scope.where(
            "users.email ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q OR orders.id::text ILIKE :q OR orders.status ILIKE :q",
            q: like
          )
        end
      end

      scope = scope.order("#{helpers.orders_sort_column} #{helpers.orders_sort_direction}")
      @pagy, @orders = pagy(scope, items: 15)
    end

    def show
      @order = Order.includes(order_items: :course).find(params[:id])
    end

    def destroy
      @order = Order.find(params[:id])
      unless @order.status == "pending" || @order.status == "canceled"
        redirect_to admin_orders_path, alert: "Smazat lze pouze neuhrazené objednávky."
        return
      end

      @order.destroy
      redirect_to admin_orders_path, notice: "Objednávka byla smazána."
    end
  end
end
