class RenameSegmentsToChaptersAndStepsToSegments < ActiveRecord::Migration[8.1]
  def up
    # segments (under Course) become chapters (Kapitola)
    rename_table :segments, :chapters

    # steps (under Segment) become segments (under Chapter)
    rename_table :steps, :segments
    rename_column :segments, :segment_id, :chapter_id

    # Rebuild foreign keys / indexes to match new hierarchy.
    remove_foreign_key :segments, column: :chapter_id, if_exists: true
    add_foreign_key :segments, :chapters, column: :chapter_id

    remove_index :chapters, column: %i[course_id position], if_exists: true
    add_index :chapters, %i[course_id position], unique: true

    remove_index :segments, column: %i[chapter_id position], if_exists: true
    remove_index :segments, column: %i[segment_id position], if_exists: true
    add_index :segments, %i[chapter_id position], unique: true
  end

  def down
    remove_index :segments, column: %i[chapter_id position], if_exists: true
    remove_foreign_key :segments, column: :chapter_id, if_exists: true

    rename_column :segments, :chapter_id, :segment_id
    rename_table :segments, :steps
    rename_table :chapters, :segments

    add_foreign_key :steps, :segments, column: :segment_id
    add_index :segments, %i[course_id position], unique: true
    add_index :steps, %i[segment_id position], unique: true
  end
end
