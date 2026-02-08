module AdminArea
  class SegmentsController < BaseController
    before_action :set_course
    before_action :set_chapter
    before_action :set_segment, only: %i[edit update destroy move_up move_down destroy_attachment]

    def new
      @segment = @chapter.segments.new
    end

    def create
      @segment = @chapter.segments.new(segment_params.except(:attachments))
      attach_files(@segment)
      if @segment.save
        redirect_to admin_course_path(@course), notice: "Segment vytvoren."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @segment.assign_attributes(segment_params.except(:attachments))
      attach_files(@segment)

      if @segment.save
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

    def destroy_attachment
      attachment = @segment.attachments.attachments.find(params[:attachment_id])
      attachment.purge
      redirect_to edit_admin_course_chapter_segment_path(@course, @chapter, @segment), notice: "Priloha smazana."
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
      params.require(:segment).permit(:title, :content, :video, attachments: [])
    end

    def attach_files(segment)
      new_files = Array(segment_params[:attachments]).reject(&:blank?)
      segment.attachments.attach(new_files) if new_files.any?
    end
  end
end
