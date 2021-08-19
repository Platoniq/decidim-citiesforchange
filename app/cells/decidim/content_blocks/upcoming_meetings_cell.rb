# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # A cell to be rendered as a content block with the upcomingm meetings published
    # in a Decidim Organization.
    class UpcomingMeetingsCell < Decidim::ViewModel
      include Decidim::Core::Engine.routes.url_helpers
      include Decidim::Meetings::Engine.routes.url_helpers
      include Decidim::ApplicationHelper
      include Decidim::SanitizeHelper
      include Decidim::IconHelper

      def show
        return if meetings.empty?

        render
      end

      def meeting_path(meeting)
        Decidim::EngineRouter.main_proxy(meeting.component).meeting_path(meeting)
      end

      def meetings
        @meetings ||= Meetings::Meeting.upcoming.where(
          component: meeting_components.find_by(id: model.settings.component_id) || meeting_components
        ).limit(meetings_to_show).order(start_time: :asc)
      end

      private

      # A MD5 hash of model attributes because is needed because
      # it ensures the cache version value will always be the same size
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/upcoming_meetings"
        hash << Digest::MD5.hexdigest(meetings.map(&:cache_key_with_version).to_s)
        hash << I18n.locale.to_s

        hash.join("/")
      end

      def meeting_components
        @meeting_components ||= Component.published.where(participatory_space: participatory_spaces, manifest_name: "meetings")
      end

      def meetings_to_show
        model.settings.count || 3
      end

      def section_title
        translated_attribute model.settings.title
      end

      def section_link
        link_to translated_attribute(model.settings.link_url) do
          translated_attribute(model.settings.link_text)
        end
      end

      def participatory_spaces
        @participatory_spaces ||= [
          Decidim::Assembly.where(organization: current_organization),
          Decidim::ParticipatoryProcess.where(organization: current_organization),
          (Decidim::Conference.where(organization: current_organization) if defined? Decidim::Conference),
          (Decidim::Consultation.where(organization: current_organization) if defined? Decidim::Consultation),
          (Decidim::Election.where(organization: current_organization) if defined? Decidim::Election),
          (Decidim::Initiative.where(organization: current_organization) if defined? Decidim::Initiative)
        ].flatten.compact
      end
    end
  end
end
