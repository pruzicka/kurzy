class RenameCourseTitleToNameAndPriceCentsToPrice < ActiveRecord::Migration[8.1]
  def change
    rename_column :courses, :title, :name
    rename_column :courses, :price_cents, :price
  end
end
