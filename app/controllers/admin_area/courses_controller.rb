module AdminArea
  class CoursesController < BaseController
    before_action :set_course, only: %i[show edit update destroy destroy_cover_image]

    def index
      authorize Course
      @courses = Course.includes(:tags).order(created_at: :desc)
    end

    def show
      authorize @course
    end

    def new
      @course = Course.new(currency: "CZK", status: "draft", price: 0)
      authorize @course
    end

    def create
      @course = Course.new(course_params)
      authorize @course
      if @course.save
        redirect_to admin_course_path(@course), notice: "Kurz vytvořen."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @course
    end

    def update
      authorize @course
      if @course.update(course_params)
        redirect_to admin_course_path(@course), notice: "Kurz upraven."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @course
      @course.destroy!
      redirect_to admin_courses_path, notice: "Kurz smazán."
    end

    def destroy_cover_image
      authorize @course
      @course.cover_image.purge if @course.cover_image.attached?
      redirect_to edit_admin_course_path(@course), notice: "Obrázek kurzu smazán."
    end

    private

    def set_course
      @course = Course.includes(chapters: :segments).find(params[:id])
    end

    def course_params
      params.require(:course).permit(:name, :description, :status, :course_type, :price, :currency, :slug, :cover_image, tag_ids: [])
    end
  end
end
