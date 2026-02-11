class FakturoidCorrectionJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    return if order.fakturoid_correction_id.present?
    return unless order.fakturoid_invoice_id.present?

    FakturoidService.new(order).create_correction!
    OrderMailer.refund_confirmation(order.reload).deliver_later
  end
end
