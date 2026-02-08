module MandatoryChapterLock
  extend ActiveSupport::Concern

  private

  # Returns the first (closest) previous mandatory chapter that still has
  # incomplete segments. Otherwise returns nil.
  #
  # completions_by_segment_id: Hash-like where keys are completed segment IDs.
  def blocking_mandatory_chapter_for(course, current_chapter, completions_by_segment_id)
    previous_chapters = course.chapters.select { |c| c.position < current_chapter.position }
    previous_chapters.sort_by(&:position).reverse_each do |ch|
      next unless ch.is_mandatory?

      segment_ids = ch.segments.map(&:id)
      next if segment_ids.empty?
      next if segment_ids.all? { |id| completions_by_segment_id.key?(id) }

      return ch
    end
    nil
  end
end

