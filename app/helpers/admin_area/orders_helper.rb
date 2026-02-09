module AdminArea
  module OrdersHelper
    SORTABLE_COLUMNS = {
      "user" => "users.email",
      "status" => "orders.status",
      "total" => "orders.total_amount",
      "created" => "orders.created_at"
    }.freeze

    def orders_sort_column
      SORTABLE_COLUMNS.fetch(params[:sort], "orders.created_at")
    end

    def orders_sort_direction
      params[:direction] == "asc" ? "asc" : "desc"
    end

    def orders_sort_link(label, key)
      direction = params[:sort] == key && params[:direction] == "asc" ? "desc" : "asc"
      link_to label,
              params.permit(:q, :page, :commit, :status, :date_from, :date_to).merge(sort: key, direction: direction),
              class: "hover:underline"
    end
  end
end
