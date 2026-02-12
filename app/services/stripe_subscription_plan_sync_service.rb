class StripeSubscriptionPlanSyncService
  def initialize(subscription_plan)
    @plan = subscription_plan
  end

  def sync!
    product = find_or_create_product!
    monthly_price = find_or_create_price!(product, "month")
    annual_price = find_or_create_price!(product, "year")

    @plan.update!(
      stripe_product_id: product.id,
      stripe_monthly_price_id: monthly_price.id,
      stripe_annual_price_id: annual_price.id
    )
  end

  private

  def find_or_create_product!
    if @plan.stripe_product_id.present?
      Stripe::Product.update(@plan.stripe_product_id, product_params)
      Stripe::Product.retrieve(@plan.stripe_product_id)
    else
      Stripe::Product.create(product_params)
    end
  end

  def find_or_create_price!(product, interval)
    existing_price_id = interval == "month" ? @plan.stripe_monthly_price_id : @plan.stripe_annual_price_id
    unit_amount = interval == "month" ? @plan.monthly_price_in_minor_units : @plan.annual_price_in_minor_units

    if existing_price_id.present?
      existing = Stripe::Price.retrieve(existing_price_id)
      if existing.unit_amount == unit_amount && existing.currency == @plan.currency.downcase
        return existing
      end
      Stripe::Price.update(existing_price_id, active: false)
    end

    Stripe::Price.create(
      product: product.id,
      unit_amount: unit_amount,
      currency: @plan.currency.downcase,
      recurring: { interval: interval }
    )
  end

  def product_params
    {
      name: @plan.name,
      metadata: { subscription_plan_id: @plan.id }
    }
  end
end
