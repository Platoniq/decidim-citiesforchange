# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Conferences::ConferenceProgramController.class_eval do
    include Decidim::FilterResource

    helper Decidim::FiltersHelper
    helper Decidim::Meetings::ApplicationHelper

    helper_method :filtered_collection, :meetings_by_month, :meetings_months

    private

    def filtered_collection
      search.results
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

    def meetings_months
      @meetings_months ||= meetings.map { |m| [m.start_time.beginning_of_month] }.uniq.flatten
    end

    def meetings_by_month
      Decidim::Conferences::ConferenceProgramMeetingsByMonth.new(meetings, months).query
    end
  end
end
