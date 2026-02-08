class CourseProgress < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :last_segment, class_name: "Segment"
end
