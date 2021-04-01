# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Medium (:m) post card
    # for an given instance of a Post
    class PostMCell < Decidim::CardMCell
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
