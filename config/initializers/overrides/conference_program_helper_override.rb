# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Conferences::ConferenceProgramHelper.class_eval do
    include Decidim::FiltersHelper
    include Decidim::CheckBoxesTreeHelper

    def filter_scopes_values
      main_scopes = current_organization.scopes.top_level

      scopes_values = main_scopes.includes(:scope_type, :children).flat_map do |scope|
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_organization)),
          scope_children_to_tree(scope)
        )
      end

      Decidim::CheckBoxesTreeHelper::TreeNode.new(
        Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.conferences.conference_program.filters.all")),
        scopes_values
      )
    end

    def scope_children_to_tree(scope)
      return unless scope.children.any?

      scope.children.includes(:scope_type, :children).flat_map do |child|
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new(child.id.to_s, translated_attribute(child.name, current_organization)),
          scope_children_to_tree(child)
        )
      end
    end

    def filter_type_values
      type_values = []
      Decidim::Meetings::Meeting::TYPE_OF_MEETING.each do |type|
        type_values << Decidim::CheckBoxesTreeHelper::TreePoint.new(type, t("decidim.meetings.meetings.filters.type_values.#{type}"))
      end

      Decidim::CheckBoxesTreeHelper::TreeNode.new(
        Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.meetings.meetings.filters.type_values.all")),
        type_values
      )
    end

    def default_period?(periods, period)
      return current_period.eql?(period) if periods.include?(current_period)

      available_periods = periods.select(&:future?).presence || periods
      available_periods.first.eql?(period)
    end

    def current_period
      Time.current.send("beginning_of_#{meetings_group_by_period}")
    end

    def period_localization_format(_period)
      meetings_group_by_period == :month ? :month_and_year : "%d %b"
    end

    # Returns the following data structure:
    #   [
    #     [
    #       { start_time: #<ActiveSupport::TimeWithZone>, end_time: #<ActiveSupport::TimeWithZone> },
    #       [
    #         { meeting: #<Decidim::Meetings::Meeting> },
    #         ...
    #       ]
    #     ],
    #     ...
    #   ]
    def meetings_by_time(time)
      meetings_by_period.find { |period, _| period.include?(time) }.last
    end
  end
end
