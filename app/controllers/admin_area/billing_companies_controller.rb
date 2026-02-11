module AdminArea
  class BillingCompaniesController < BaseController
    before_action :set_billing_company, only: %i[edit update destroy]

    def index
      authorize BillingCompany
      @billing_companies = BillingCompany.order(created_at: :desc)
    end

    def new
      @billing_company = BillingCompany.new
      authorize @billing_company
    end

    def create
      @billing_company = BillingCompany.new(billing_company_params)
      authorize @billing_company
      if @billing_company.save
        redirect_to admin_billing_companies_path, notice: "Fakturační firma byla vytvořena."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @billing_company
    end

    def update
      authorize @billing_company
      if @billing_company.update(billing_company_params)
        redirect_to admin_billing_companies_path, notice: "Fakturační firma byla uložena."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @billing_company
      @billing_company.destroy
      redirect_to admin_billing_companies_path, notice: "Fakturační firma byla smazána."
    end

    private

    def set_billing_company
      @billing_company = BillingCompany.find(params[:id])
    end

    def billing_company_params
      params.require(:billing_company).permit(:name, :street, :city, :zip, :country, :ico, :dic, :fakturoid_slug, :active)
    end
  end
end
