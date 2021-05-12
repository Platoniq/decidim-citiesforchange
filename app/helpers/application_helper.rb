# frozen_string_literal: true

module ApplicationHelper
  def conference_meeting_months(meetings)
    meetings.map { |m| [m.start_time.beginning_of_month] }.uniq.flatten
  end

  def conference_meetings_for_month(component, month, user)
    meetings = Decidim::Conferences::ConferenceProgramMeetingsByMonth.new(component, month, user).query

    meetings_by_time = {}
    meetings.each do |meeting|
      meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] ||= []
      meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] << { meeting: meeting }
    end
    meetings_by_time
  end

  def default_month?(months, month)
    return current_month?(month) if months.include?(Time.current.beginning_of_month)

    available_months = months.select(&:future?).presence || months
    available_months.first.eql?(month)
  end

  def current_month?(month)
    Time.current.beginning_of_month.eql?(month)
  end
end
