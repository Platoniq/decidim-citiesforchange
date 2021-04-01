# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # A cell to be rendered as a content block with the upcomingm meetings published
    # in a Decidim Organization.
    class UpcomingMeetingsCell < Decidim::ViewModel
      include Decidim::Core::Engine.routes.url_helpers
      include Decidim::Meetings::Engine.routes.url_helpers
      include Decidim::IconHelper
      include Decidim::SanitizeHelper

      def show
        return if meetings.empty?

        render
      end

      def meeting_path(meeting)
        Decidim::EngineRouter.main_proxy(meeting.component).meeting_path(meeting)
      end

      def meetings
        @meetings ||= Meetings::Meeting.upcoming.where(
          component: meeting_components
        ).limit(meetings_to_show).order(start_time: :asc)
      end

      private

      # A MD5 hash of model attributes because is needed because
      # it ensures the cache version value will always be the same size
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/upcoming_meetings"
        hash << Digest::MD5.hexdigest(valid_meetings.map(&:cache_key_with_version).to_s)
        hash << I18n.locale.to_s

        hash.join("/")
      end

      def meeting_components
        @meeting_components ||= Component.published.where(manifest_name: "meetings")
      end

      def meetings_to_show
        options[:meetings_count] || 3
      end
    end
  end
end
