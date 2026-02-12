module AdminArea
  class SubscriptionPlansController < BaseController
    before_action :set_subscription_plan, only: %i[show edit update destroy destroy_cover_image]

    def index
      authorize SubscriptionPlan
      @subscription_plans = SubscriptionPlan.includes(:author).order(created_at: :desc)
    end

    def show
      authorize @subscription_plan
    end

    def new
      @subscription_plan = SubscriptionPlan.new(currency: "CZK", status: "draft", monthly_price: 0, annual_discount_percent: 0)
      authorize @subscription_plan
    end

    def create
      @subscription_plan = SubscriptionPlan.new(subscription_plan_params)
      authorize @subscription_plan
      if @subscription_plan.save
        redirect_to admin_subscription_plan_path(@subscription_plan), notice: "Předplatné vytvořeno."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @subscription_plan
    end

    def update
      authorize @subscription_plan
      if @subscription_plan.update(subscription_plan_params)
        redirect_to admin_subscription_plan_path(@subscription_plan), notice: "Předplatné upraveno."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @subscription_plan
      @subscription_plan.destroy!
      redirect_to admin_subscription_plans_path, notice: "Předplatné smazáno."
    end

    def destroy_cover_image
      authorize @subscription_plan
      @subscription_plan.cover_image.purge if @subscription_plan.cover_image.attached?
      redirect_to edit_admin_subscription_plan_path(@subscription_plan), notice: "Obrázek smazán."
    end

    private

    def set_subscription_plan
      @subscription_plan = SubscriptionPlan.find(params[:id])
    end

    def subscription_plan_params
      params.require(:subscription_plan).permit(:name, :slug, :status, :monthly_price, :currency, :annual_discount_percent, :author_id, :description, :cover_image)
    end
  end
end
