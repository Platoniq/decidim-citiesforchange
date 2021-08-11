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
