module AdminArea
  class CoursesController < BaseController
    before_action :set_course, only: %i[show edit update destroy]

    def index
      @courses = Course.order(created_at: :desc)
    end

    def show
    end

    def new
      @course = Course.new(currency: "CZK", status: "draft", price: 0)
    end

    def create
      @course = Course.new(course_params)
      if @course.save
        redirect_to admin_course_path(@course), notice: "Kurz vytvoren."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @course.update(course_params)
        redirect_to admin_course_path(@course), notice: "Kurz upraven."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course.destroy!
      redirect_to admin_courses_path, notice: "Kurz smazan."
    end

    private

    def set_course
      @course = Course.includes(chapters: :segments).find(params[:id])
    end

    def course_params
      params.require(:course).permit(:name, :description, :status, :price, :currency, :slug)
    end
  end
end
