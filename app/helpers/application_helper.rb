# frozen_string_literal: true

module ApplicationHelper
  def filtered_meetings?
    current_organization.degrowth?
  end

  def conference_meetings_for_month(month)
    collection = filtered_meetings? ? filtered_collection : collection
    meetings = Decidim::Conferences::ConferenceProgramMeetingsByMonth.new(collection, month).query

    meetings_by_time = {}
    meetings.each do |meeting|
      meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] ||= []
      meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] << { meeting: meeting }
    end
    meetings_by_time
  end

  def default_month?(month)
    return current_month?(month) if meetings_months.include?(Time.current.beginning_of_month)

    available_months = meetings_months.select(&:future?).presence || meetings_months
    available_months.first.eql?(month)
  end

  def current_month?(month)
    Time.current.beginning_of_month.eql?(month)
  end
end
