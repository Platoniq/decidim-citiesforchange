# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Conferences::ConferenceProgramController.class_eval do
    include Decidim::FilterResource

    helper_method :meetings_group_by_period, :time_periods, :meetings_by_period

    private

    # Method overrided
    # Same scope but with order
    def collection
      order(meetings)
    end

    # Method overrided
    # Same scope but without order
    def meetings
      return unless meeting_component.published? || !meeting_component.presence

      @meetings ||= Decidim::Meetings::Meeting.where(component: meeting_component).visible_meeting_for(current_user)
    end

    # Method overrided
    # We need to map #collection instead, since #meetings is unordered now.
    def meeting_days
      @meeting_days ||= collection.map { |meeting| meeting.start_time.to_date }.uniq
    end

    def order(relation)
      relation.order(:start_time)
    end

    def filtered_collection
      order(search.results)
    end

    def search_klass
      Decidim::Meetings::MeetingSearch
    end

    def default_search_params
      {
        scope: meetings
      }
    end

    def default_filter_params
      {
        search_text: "",
        type: default_filter_type_params,
        scope_id: default_filter_scope_params,
        category_id: default_filter_category_params
      }
    end

    def default_filter_type_params
      %w(all) + Decidim::Meetings::Meeting::TYPE_OF_MEETING
    end

    def default_filter_scope_params
      %w(all global) + current_organization.scopes.ids.compact.map(&:to_s)
    end

    def default_filter_category_params
      %w(all) + current_participatory_space.categories.ids.compact.map(&:to_s)
    end

    def default_filter_origin_params
      filter_origin_params = %w(citizens)
      filter_origin_params << "official"
      filter_origin_params << "user_group" if current_organization.user_groups_enabled?
      filter_origin_params
    end

    def context_params
      {
        current_user: current_user,
        organization: current_organization,
        component: meeting_component
      }
    end

    def meetings_group_by_period
      current_organization.conference_program_meetings_group_by
    end

    def time_periods
      send("meeting_#{meetings_group_by_period}s")
    end

    def meeting_months
      @meeting_months ||= collection.map { |meeting| meeting.start_time.beginning_of_month }.uniq
    end

    def meetings_by_period
      @meetings_by_period ||= begin
        relation = current_organization.filtered_conference_program_meetings? ? filtered_collection : collection
        periods = time_periods.map do |time_period|
          time_period.send("beginning_of_#{meetings_group_by_period}")..time_period.send("end_of_#{meetings_group_by_period}")
        end

        Decidim::Conferences::ConferenceProgramMeetingsByPeriod.new(relation, periods).query
      end
    end
  end
end
