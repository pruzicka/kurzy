module AdminArea
  class SegmentsController < BaseController
    before_action :set_course
    before_action :set_chapter
    before_action :set_segment, only: %i[edit update destroy move_up move_down destroy_attachment destroy_cover_image destroy_video]
    before_action :load_media_assets, only: %i[new edit create update]

    def new
      @segment = @chapter.segments.new
      authorize @segment
    end

    def create
      @segment = @chapter.segments.new(segment_params.except(:attachments))
      authorize @segment
      attach_files(@segment)
      if @segment.save
        sync_media_library!(@segment)
        redirect_to admin_course_path(@course), notice: "Segment vytvořen."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @segment
    end

    def update
      authorize @segment
      @segment.assign_attributes(segment_params.except(:attachments))
      attach_files(@segment)

      if @segment.save
        sync_media_library!(@segment)
        redirect_to admin_course_path(@course), notice: "Segment upraven."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @segment
      @segment.destroy!
      redirect_to admin_course_path(@course), notice: "Segment smazán."
    end

    def move_up
      authorize @segment
      @segment.move_up!
      respond_to_reorder
    end

    def move_down
      authorize @segment
      @segment.move_down!
      respond_to_reorder
    end

    def destroy_attachment
      authorize @segment
      attachment = @segment.attachments.attachments.find(params[:attachment_id])
      attachment.purge
      redirect_to edit_admin_course_chapter_segment_path(@course, @chapter, @segment), notice: "Příloha smazána."
    end

    def destroy_cover_image
      authorize @segment
      @segment.cover_image.purge if @segment.cover_image.attached?
      redirect_to edit_admin_course_chapter_segment_path(@course, @chapter, @segment), notice: "Náhled smazán."
    end

    def destroy_video
      authorize @segment
      @segment.video.purge if @segment.video.attached?
      redirect_to edit_admin_course_chapter_segment_path(@course, @chapter, @segment), notice: "Video smazáno."
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
      params.require(:segment).permit(:title, :content, :video, :cover_image, :video_asset_id, :cover_asset_id, :is_free_preview, attachments: [])
    end

    def attach_files(segment)
      new_files = Array(segment_params[:attachments]).reject(&:blank?)
      segment.attachments.attach(new_files) if new_files.any?
    end

    def load_media_assets
      @video_assets = MediaAsset.where(media_type: "video").order(created_at: :desc)
      @image_assets = MediaAsset.where(media_type: "image").order(created_at: :desc)
    end

    def respond_to_reorder
      @course.chapters.reload.each { |c| c.segments.reload }
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("course_chapters", partial: "admin_area/courses/chapters_list", locals: { course: @course }) }
        format.html { redirect_to admin_course_path(@course) }
      end
    end

    def sync_media_library!(segment)
      if segment.video.attached?
        if segment.video_asset.blank? || segment.video_asset.file.blob_id != segment.video.blob_id
          asset = MediaAsset.create!(title: segment.video.filename.to_s, media_type: "video", file: segment.video.blob)
          segment.update_column(:video_asset_id, asset.id)
        end
      end

      if segment.cover_image.attached?
        if segment.cover_asset.blank? || segment.cover_asset.file.blob_id != segment.cover_image.blob_id
          asset = MediaAsset.create!(title: segment.cover_image.filename.to_s, media_type: "image", file: segment.cover_image.blob)
          segment.update_column(:cover_asset_id, asset.id)
        end
      end
    end
  end
end
