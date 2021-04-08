# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Medium (:m) post card
    # for an given instance of a Post
    class PostMCell < Decidim::CardMCell
      include Decidim::Blogs::Engine.routes.url_helpers
      include Decidim::Blogs::PostsHelper

      def description
        link = resource_path
        body = translated_attribute(model.body)
        tail = "... #{link_to(t("read_more", scope: "decidim.blogs"), link)}".html_safe
        CGI.unescapeHTML html_truncate(body, max_length: has_image? ? 140 : 360, tail: tail)
      end

      private

      def has_image?
        model.photo.present?
      end

      def has_actions?
        false
      end

      def resource_image_path
        model.photo.url
      end

      def endorsements_count
        with_tooltip t("decidim.endorsable.endorsements") do
          "#{icon("bullhorn", class: "icon--small")} #{model.endorsements_count}"
        end
      end
    end
  end
end
