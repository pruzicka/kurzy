module ApplicationHelper
  include Pagy::Frontend

  INPUT_CLASS = "w-full rounded-2xl border border-gray-300 bg-white px-3 py-2.5 text-sm text-gray-900 shadow-sm outline-none focus:border-gray-900 focus:ring-2 focus:ring-gray-900/15".freeze
  INPUT_ERROR_CLASS = "w-full rounded-2xl border border-rose-400 bg-rose-50 px-3 py-2.5 text-sm text-gray-900 shadow-sm outline-none focus:border-rose-500 focus:ring-2 focus:ring-rose-500/15".freeze

  def input_class_for(model, attribute)
    model.errors[attribute].any? ? INPUT_ERROR_CLASS : INPUT_CLASS
  end
end
