# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Conferences::ConferenceProgramController.class_eval do
    include Decidim::FilterResource

    helper Decidim::FiltersHelper
    helper Decidim::Meetings::ApplicationHelper

    helper_method :meetings_months, :meetings_by_time

    private

    def collection
      order(meetings)
    end

    # Same but without order
    def meetings
      return unless meeting_component.published? || !meeting_component.presence

      @meetings ||= Decidim::Meetings::Meeting.where(component: meeting_component).visible_meeting_for(current_user)
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

    def meetings_months
      @meetings_months ||= collection.map { |m| [m.start_time.beginning_of_month] }.uniq.flatten
    end

    def meetings_by_time
      relation = current_organization.filtered_conference_program_meetings? ? filtered_collection : collection
      periods = meetings_months.map { |month| [month.beginning_of_month..month.end_of_month] }
      Decidim::Conferences::ConferenceProgramMeetingsByPeriod.new(relation, periods).query.to_a
    end
  end
end
