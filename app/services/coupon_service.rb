class CouponService
  Result = Struct.new(:success?, :error, keyword_init: true)

  def initialize(cart)
    @cart = cart
  end

  def apply(code)
    coupon = Coupon.find_by(code: code.to_s.strip.upcase)
    return Result.new(success?: false, error: "Slevový kód nebyl nalezen.") unless coupon
    return Result.new(success?: false, error: "Slevový kód není aktivní.") unless coupon.available_for?(@cart.currency)

    @cart.update!(coupon: coupon)
    Result.new(success?: true)
  end

  def remove
    @cart.update!(coupon: nil)
    Result.new(success?: true)
  end
end
