class OrderMailer < ApplicationMailer
  def purchase_confirmation(order)
    @order = order
    @user = order.user
    @items = order.order_items.includes(:course)

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Potvrzení objednávky ##{order.id}"
    )
  end

  def invoice_ready(order)
    @order = order
    @user = order.user
    @items = order.order_items.includes(:course)

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Faktura k objednávce ##{order.id}"
    )
  end
end
