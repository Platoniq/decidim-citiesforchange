# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters meetings for component and month
    class ConferenceProgramMeetingsByMonth < Rectify::Query
      def initialize(meetings, month)
        @meetings = meetings
        @month = month
      end

      def query
        @meetings
          .where(start_time: @month.beginning_of_month..@month.end_of_month)
          .order(start_time: :asc)
      end
    end
  end
end


# def conference_meetings_by_months
#   meetings = filtered_meetings? ? filtered_collection : collection
#   meetings_by_month = Decidim::Conferences::ConferenceProgramMeetingsByMonth.new(meetings, months).query

#   meetings_months
#   meetings_by_time = {}
#   meetings_by_month.each do |meeting|
#     meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] ||= []
#     meetings_by_time[start_time: meeting.start_time, end_time: meeting.end_time] << { meeting: meeting }
#   end
#   meetings_by_time
# end
