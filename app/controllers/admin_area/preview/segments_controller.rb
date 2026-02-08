module AdminArea
  module Preview
    class SegmentsController < BaseController
      before_action :set_course
      before_action :set_chapter
      before_action :set_segment

      def show
        @next_segment = next_segment_for(@course, @segment)
        @completions_by_segment_id = {}
        render "segments/show"
      end

      private

      def set_course
        @course = Course.includes(chapters: :segments).find(params[:course_id])
      end

      def set_chapter
        @chapter = @course.chapters.find(params[:chapter_id])
      end

      def set_segment
        @segment = @chapter.segments.find(params[:id])
      end

      def next_segment_for(course, segment)
        ordered = course.chapters.flat_map(&:segments)
        idx = ordered.index(segment)
        return nil unless idx

        ordered[idx + 1]
      end
    end
  end
end
