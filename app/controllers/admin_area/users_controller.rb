module AdminArea
  class UsersController < BaseController
    def index
      authorize User
      @users = User.order(created_at: :desc).includes(:enrollments, :orders)
    end

    def show
      @user = User.find(params[:id])
      authorize @user
      @orders = @user.orders.order(created_at: :desc)
      @enrollments = @user.enrollments.includes(course: { chapters: :segments }).order(created_at: :desc)

      course_ids = @enrollments.map(&:course_id)
      @segments_count_by_course_id =
        if course_ids.empty?
          {}
        else
          Segment.joins(chapter: :course)
                 .where(courses: { id: course_ids })
                 .group("courses.id")
                 .count
        end

      @completed_count_by_course_id =
        if course_ids.empty?
          {}
        else
          SegmentCompletion.joins(segment: { chapter: :course })
                           .where(user: @user, courses: { id: course_ids })
                           .group("courses.id")
                           .count
        end

      @progress_by_course_id = @user.course_progresses.where(course_id: course_ids).index_by(&:course_id)
    end
  end
end
