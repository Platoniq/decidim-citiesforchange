# frozen_string_literal: true

module ApplicationHelper
  def default_month?(months, month)
    return current_month?(month) if months.include?(Time.current.beginning_of_month)

    available_months = months.select(&:future?).presence || months
    available_months.first.eql?(month)
  end

  def current_month?(month)
    Time.current.beginning_of_month.eql?(month)
  end
end
