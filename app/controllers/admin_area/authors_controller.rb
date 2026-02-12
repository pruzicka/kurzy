module AdminArea
  class AuthorsController < BaseController
    before_action :set_author, only: %i[show edit update destroy destroy_profile_image]

    def index
      authorize Author
      @authors = Author.order(created_at: :desc)
    end

    def show
      authorize @author
    end

    def new
      @author = Author.new
      authorize @author
    end

    def create
      @author = Author.new(author_params)
      authorize @author
      if @author.save
        redirect_to admin_author_path(@author), notice: "Autor vytvořen."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @author
    end

    def update
      authorize @author
      if @author.update(author_params)
        redirect_to admin_author_path(@author), notice: "Autor upraven."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @author
      @author.destroy!
      redirect_to admin_authors_path, notice: "Autor smazán."
    end

    def destroy_profile_image
      authorize @author
      @author.profile_image.purge if @author.profile_image.attached?
      redirect_to edit_admin_author_path(@author), notice: "Profilový obrázek smazán."
    end

    private

    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:first_name, :last_name, :email, :slug, :bio, :profile_image)
    end
  end
end
