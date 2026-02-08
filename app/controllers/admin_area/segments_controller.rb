module AdminArea
  class SegmentsController < BaseController
    before_action :set_course
    before_action :set_chapter
    before_action :set_segment, only: %i[edit update destroy move_up move_down]

    def new
      @segment = @chapter.segments.new
    end

    def create
      @segment = @chapter.segments.new(segment_params)
      if @segment.save
        redirect_to admin_course_path(@course), notice: "Segment vytvoren."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @segment.update(segment_params)
        redirect_to admin_course_path(@course), notice: "Segment upraven."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @segment.destroy!
      redirect_to admin_course_path(@course), notice: "Segment smazan."
    end

    def move_up
      @segment.move_up!
      redirect_to admin_course_path(@course)
    end

    def move_down
      @segment.move_down!
      redirect_to admin_course_path(@course)
    end

    private

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_chapter
      @chapter = @course.chapters.find(params[:chapter_id])
    end

    def set_segment
      @segment = @chapter.segments.find(params[:id])
    end

    def segment_params
      params.require(:segment).permit(:title, :content)
    end
  end
end
