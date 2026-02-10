class AdminNotificationMailer < ApplicationMailer
  def new_order(order)
    @order = order
    @user = order.user
    @items = order.order_items.includes(:course)

    mail(
      to: "kurzy@pohybjezivot.cz",
      subject: "Nová objednávka ##{order.id} — #{@user.email}"
    )
  end
end
