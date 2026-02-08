module AdminArea
  module Preview
    class CoursesController < BaseController
      def index
        @courses = Course.order(created_at: :desc)
        @completions_by_segment_id = {}
        render "courses/index"
      end

      def show
        @course = Course.includes(chapters: :segments).find(params[:id])
        @completions_by_segment_id = {}
        render "courses/show"
      end
    end
  end
end
