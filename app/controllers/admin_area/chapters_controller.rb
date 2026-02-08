module AdminArea
  class ChaptersController < BaseController
    before_action :set_course
    before_action :set_chapter, only: %i[edit update destroy move_up move_down]

    def new
      @chapter = @course.chapters.new
    end

    def create
      @chapter = @course.chapters.new(chapter_params)
      if @chapter.save
        redirect_to admin_course_path(@course), notice: "Kapitola vytvorena."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @chapter.update(chapter_params)
        redirect_to admin_course_path(@course), notice: "Kapitola upravena."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @chapter.destroy!
      redirect_to admin_course_path(@course), notice: "Kapitola smazana."
    end

    def move_up
      @chapter.move_up!
      redirect_to admin_course_path(@course)
    end

    def move_down
      @chapter.move_down!
      redirect_to admin_course_path(@course)
    end

    private

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_chapter
      @chapter = @course.chapters.find(params[:id])
    end

    def chapter_params
      params.require(:chapter).permit(:title, :is_mandatory)
    end
  end
end
