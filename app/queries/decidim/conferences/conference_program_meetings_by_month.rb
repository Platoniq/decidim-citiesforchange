# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters meetings for component and month
    class ConferenceProgramMeetingsByMonth < Rectify::Query
      def initialize(component, month, user = nil)
        @component = component
        @month = month
        @user = user
      end

      def query
        Rectify::Query.merge(
          ConferenceProgramMeetings.new(@component, @user)
        ).query.where(start_time: @month.beginning_of_month..@month.end_of_month).order(start_time: :asc)
      end
    end
  end
end
