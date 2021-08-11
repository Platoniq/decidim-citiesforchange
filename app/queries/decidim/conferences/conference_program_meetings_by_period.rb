# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters meetings by period
    # Returns a Hash
    class ConferenceProgramMeetingsByPeriod < Rectify::Query
      def initialize(relation, periods)
        @relation = relation
        @periods = periods
      end

      def query
        @periods.each_with_object({}) do |period, hash|
          hash[period] = {}
          meetings = meetings_for_period(@relation, period)

          if meetings.any?
            meetings.each do |meeting|
              key = { start_time: meeting.start_time, end_time: meeting.end_time }
              hash[period][key] ||= []
              hash[period][key] << { meeting: meeting }
            end
          else
            hash[period][{ no_meetings_for_period: period }] = []
          end
        end
      end

      private

      def meetings_for_period(relation, period)
        relation
          .where(start_time: period)
          .order(start_time: :asc)
      end
    end
  end
end
