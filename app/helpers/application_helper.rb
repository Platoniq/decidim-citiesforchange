# frozen_string_literal: true

module ApplicationHelper
  def filtered_meetings?
    current_organization.degrowth?
  end

  def conference_meetings_by_months
    meetings = filtered_meetings? ? filtered_collection : collection
    meetings_by_time = {}

    meetings_months.each do |month|
      meetings_by_month = Decidim::Conferences::ConferenceProgramMeetingsByMonth.new(meetings, month).query

      meetings_by_month.each do |meeting|
        key = {
          start_time: meeting.start_time,
          end_time: meeting.end_time,
          month: meeting.start_time.beginning_of_month
        }

        meetings_by_time[key] ||= []
        meetings_by_time[key] << { meeting: meeting }
      end
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
