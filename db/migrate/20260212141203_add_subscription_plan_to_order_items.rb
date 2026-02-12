class AddSubscriptionPlanToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :order_items, :subscription_plan, foreign_key: true, null: true
    change_column_null :order_items, :course_id, true
  end
end
