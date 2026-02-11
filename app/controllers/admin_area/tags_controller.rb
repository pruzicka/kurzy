module AdminArea
  class TagsController < BaseController
    before_action :set_tag, only: %i[edit update destroy]

    def index
      authorize Tag
      @tags = Tag.order(:name)
    end

    def new
      @tag = Tag.new
      authorize @tag
    end

    def create
      @tag = Tag.new(tag_params)
      authorize @tag
      if @tag.save
        redirect_to admin_tags_path, notice: "Štítek vytvořen."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @tag
    end

    def update
      authorize @tag
      if @tag.update(tag_params)
        redirect_to admin_tags_path, notice: "Štítek upraven."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @tag
      @tag.destroy!
      redirect_to admin_tags_path, notice: "Štítek smazán."
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end
