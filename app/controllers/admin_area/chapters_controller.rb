module AdminArea
  class ChaptersController < BaseController
    before_action :set_course
    before_action :set_chapter, only: %i[edit update destroy move_up move_down]

    def new
      @chapter = @course.chapters.new
      authorize @chapter
    end

    def create
      @chapter = @course.chapters.new(chapter_params)
      authorize @chapter
      if @chapter.save
        redirect_to admin_course_path(@course), notice: "Kapitola vytvořena."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @chapter
    end

    def update
      authorize @chapter
      if @chapter.update(chapter_params)
        redirect_to admin_course_path(@course), notice: "Kapitola upravena."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @chapter
      @chapter.destroy!
      redirect_to admin_course_path(@course), notice: "Kapitola smazána."
    end

    def move_up
      authorize @chapter
      @chapter.move_up!
      respond_to_reorder
    end

    def move_down
      authorize @chapter
      @chapter.move_down!
      respond_to_reorder
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

    def respond_to_reorder
      @course.chapters.reload
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("course_chapters", partial: "admin_area/courses/chapters_list", locals: { course: @course }) }
        format.html { redirect_to admin_course_path(@course) }
      end
    end
  end
end
