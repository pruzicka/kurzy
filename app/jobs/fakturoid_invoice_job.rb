class FakturoidInvoiceJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    return if order.fakturoid_invoice?

    FakturoidService.new(order).create_invoice!
    OrderMailer.invoice_ready(order.reload).deliver_later
  end
end
