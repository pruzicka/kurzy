class FakturoidService
  def initialize(order)
    @order = order
    @company = BillingCompany.current
  end

  def create_invoice!
    return unless @company

    subject = find_or_create_subject!
    invoice = create_fakturoid_invoice!(subject)
    mark_as_paid!(invoice)

    @order.update!(
      fakturoid_invoice_id: invoice.id,
      fakturoid_invoice_number: invoice.number,
      fakturoid_public_url: invoice.public_html_url,
      fakturoid_private_url: invoice.html_url,
      fakturoid_subject_id: subject.id
    )
  end

  def create_correction!
    return unless @company
    return unless @order.fakturoid_invoice_id.present?
    return if @order.fakturoid_correction_id.present?

    correction = client.invoices.create(
      document_type: "correction",
      correction_id: @order.fakturoid_invoice_id,
      subject_id: @order.fakturoid_subject_id,
      currency: @order.currency,
      payment_method: "card",
      issued_on: Date.current.iso8601,
      lines: build_correction_lines
    )

    @order.update!(
      fakturoid_correction_id: correction.id,
      fakturoid_correction_number: correction.number,
      fakturoid_correction_url: correction.html_url
    )
  end

  private

  def find_or_create_subject!
    if @order.fakturoid_subject_id.present?
      return client.subjects.find(@order.fakturoid_subject_id)
    end

    existing = client.subjects.search(query: @order.user.email)
    if existing.body.any?
      subject = existing.body.first
      client.subjects.update(subject["id"], subject_params)
      return client.subjects.find(subject["id"])
    end

    client.subjects.create(subject_params)
  end

  def subject_params
    {
      name: @order.billing_name.presence || @order.user.name,
      email: @order.user.email,
      street: @order.billing_street,
      city: @order.billing_city,
      zip: @order.billing_zip,
      country: @order.billing_country,
      registration_number: @order.billing_ico,
      vat_number: @order.billing_dic
    }.compact
  end

  def create_fakturoid_invoice!(subject)
    subject_id = subject.respond_to?(:id) ? subject.id : subject["id"]

    client.invoices.create(
      subject_id: subject_id,
      currency: @order.currency,
      payment_method: "card",
      issued_on: Date.current.iso8601,
      lines: build_lines
    )
  end

  def mark_as_paid!(invoice)
    invoice_id = invoice.respond_to?(:id) ? invoice.id : invoice["id"]

    client.invoice_payments.create(invoice_id, paid_on: Date.current.iso8601)
  end

  def build_lines
    precision = @order.currency_precision

    lines = @order.order_items.includes(:course, :subscription_plan).map do |item|
      unit_price = precision.zero? ? item.unit_amount : item.unit_amount / 100.0

      line_name = if item.subscription_plan.present?
                    "Předplatné - #{item.display_name}"
                  else
                    "#{item.course.course_type_label} - #{item.display_name}"
                  end

      {
        name: line_name,
        quantity: item.quantity,
        unit_price: unit_price,
        vat_rate: 0
      }
    end

    if @order.discount_amount.positive?
      discount_price = precision.zero? ? @order.discount_amount : @order.discount_amount / 100.0

      lines << {
        name: "Sleva#{@order.coupon ? " (#{@order.coupon.code})" : ""}",
        quantity: 1,
        unit_price: -discount_price,
        vat_rate: 0
      }
    end

    lines
  end

  def build_correction_lines
    precision = @order.currency_precision

    lines = @order.order_items.includes(:course, :subscription_plan).map do |item|
      unit_price = precision.zero? ? item.unit_amount : item.unit_amount / 100.0

      line_name = if item.subscription_plan.present?
                    "Předplatné - #{item.display_name}"
                  else
                    "#{item.course.course_type_label} - #{item.display_name}"
                  end

      {
        name: line_name,
        quantity: item.quantity,
        unit_price: -unit_price,
        vat_rate: 0
      }
    end

    if @order.discount_amount.positive?
      discount_price = precision.zero? ? @order.discount_amount : @order.discount_amount / 100.0

      lines << {
        name: "Sleva#{@order.coupon ? " (#{@order.coupon.code})" : ""}",
        quantity: 1,
        unit_price: discount_price,
        vat_rate: 0
      }
    end

    lines
  end

  def client
    @client ||= Fakturoid.client
  end
end
