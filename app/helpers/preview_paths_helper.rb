module PreviewPathsHelper
  def admin_preview?
    !!@admin_preview
  end

  def courses_list_path(**params)
    admin_preview? ? admin_preview_courses_path(**params) : courses_path(**params)
  end

  def course_show_path(course, **params)
    admin_preview? ? admin_preview_course_path(course, **params) : course_path(course, **params)
  end

  def segment_show_path(course, chapter, segment, **params)
    if admin_preview?
      admin_preview_course_chapter_segment_path(course, chapter, segment, **params)
    else
      course_chapter_segment_path(course, chapter, segment, **params)
    end
  end
end
