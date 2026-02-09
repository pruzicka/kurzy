module AdminArea
  class OrdersController < BaseController
    def index
      @query = params[:q].to_s.strip
      @status = params[:status].to_s.strip
      @date_from = parse_date(params[:date_from])
      @date_to = parse_date(params[:date_to])
      scope = Order.includes(:user, :coupon).left_joins(:user)
      if @query.present?
        like = "%#{@query}%"
        adapter = ActiveRecord::Base.connection.adapter_name.downcase
        if adapter.include?("sqlite")
          scope = scope.where(
            "LOWER(users.email) LIKE :q OR LOWER(users.first_name) LIKE :q OR LOWER(users.last_name) LIKE :q OR CAST(orders.id AS TEXT) LIKE :q OR LOWER(orders.status) LIKE :q",
            q: like.downcase
          )
        else
          scope = scope.where(
            "users.email ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q OR orders.id::text ILIKE :q OR orders.status ILIKE :q",
            q: like
          )
        end
      end

      if @status.present? && Order::STATUSES.include?(@status)
        scope = scope.where(status: @status)
      end

      if @date_from && @date_to
        scope = scope.where(created_at: @date_from.beginning_of_day..@date_to.end_of_day)
      elsif @date_from
        scope = scope.where("orders.created_at >= ?", @date_from.beginning_of_day)
      elsif @date_to
        scope = scope.where("orders.created_at <= ?", @date_to.end_of_day)
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

    def parse_date(value)
      return nil if value.blank?
      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
