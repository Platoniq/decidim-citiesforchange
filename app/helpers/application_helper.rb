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
end
