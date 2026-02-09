module AdminArea
  class CouponsController < BaseController
    before_action :set_coupon, only: %i[show edit update destroy]

    def index
      @coupons = Coupon.order(created_at: :desc)
    end

    def new
      @coupon = Coupon.new
    end

    def create
      @coupon = Coupon.new(coupon_params)
      if @coupon.save
        redirect_to admin_coupons_path, notice: "Slevový kód byl vytvořen."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @redemptions = @coupon.coupon_redemptions.includes(:order, :user).order(redeemed_at: :desc)
    end

    def edit
    end

    def update
      if @coupon.update(coupon_params)
        redirect_to admin_coupons_path, notice: "Slevový kód byl uložen."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @coupon.destroy
      redirect_to admin_coupons_path, notice: "Slevový kód byl smazán."
    end

    private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:code, :name, :notes, :discount_type, :value, :currency, :starts_at, :ends_at, :max_redemptions, :active)
    end
  end
end
