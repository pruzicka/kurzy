module AdminArea
  class OrdersController < BaseController
    def index
      authorize Order
      @query = params[:q].to_s.strip
      @status = params[:status].to_s.strip
      @date_from = parse_date(params[:date_from])
      @date_to = parse_date(params[:date_to])
      scope = Order.includes(:user, :coupon).left_joins(:user)
      if @query.present?
        like = "%#{@query}%"
        scope = scope.where(
          "users.email ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q OR orders.id::text ILIKE :q OR orders.status ILIKE :q",
          q: like
        )
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
      authorize @order
    end

    def destroy
      @order = Order.find(params[:id])
      authorize @order
      @order.destroy
      redirect_to admin_orders_path, notice: "Objednávka byla smazána."
    end

    def create_invoice
      @order = Order.find(params[:id])
      authorize @order, :show?
      FakturoidInvoiceJob.perform_later(@order.id)
      redirect_to admin_order_path(@order), notice: "Faktura se vytváří na pozadí."
    end

    def resend_invoice_email
      @order = Order.find(params[:id])
      authorize @order, :show?
      OrderMailer.invoice_ready(@order).deliver_later
      redirect_to admin_order_path(@order), notice: "E-mail s fakturou byl odeslán."
    end

    def parse_date(value)
      return nil if value.blank?
      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
