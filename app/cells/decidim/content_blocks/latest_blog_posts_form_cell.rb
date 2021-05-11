# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class LatestBlogPostsFormCell < Decidim::ViewModel
      alias form model

      def content_block
        options[:content_block]
      end

      def blog
        @blog ||= Decidim::Component.find_by(id: form.object.settings.try(:blog_id))
      end
    end
  end
end
