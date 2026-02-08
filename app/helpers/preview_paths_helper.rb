module PreviewPathsHelper
  def admin_preview?
    !!@admin_preview
  end

  def courses_list_path
    admin_preview? ? admin_preview_courses_path : courses_path
  end

  def course_show_path(course)
    admin_preview? ? admin_preview_course_path(course) : course_path(course)
  end

  def segment_show_path(course, chapter, segment)
    admin_preview? ? admin_preview_course_chapter_segment_path(course, chapter, segment) : course_chapter_segment_path(course, chapter, segment)
  end
end

