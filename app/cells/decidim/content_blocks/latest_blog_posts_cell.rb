# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # A cell to be rendered as a content block with the latest blog posts published
    # in a Decidim Organization.
    class LatestBlogPostsCell < Decidim::ViewModel
      include Decidim::Core::Engine.routes.url_helpers
      include Decidim::Blogs::PostsHelper

      def show
        return if posts.empty?

        render
      end

      def post_path(post)
        Decidim::EngineRouter.main_proxy(post.component).post_path(post)
      end

      def posts
        @posts ||= Blogs::Post.where(
          component: blog_components.find_by(id: model.settings.blog_id) || blog_components
        ).limit(posts_to_show).order(created_at: :desc)
      end

      private

      # A MD5 hash of model attributes because is needed because
      # it ensures the cache version value will always be the same size
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/latest_blog_posts"
        hash << Digest::MD5.hexdigest(posts.map(&:cache_key_with_version).to_s)
        hash << I18n.locale.to_s

        hash.join("/")
      end

      def blog_components
        @blog_components ||= Component.published.where(manifest_name: "blogs")
      end

      def posts_to_show
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
    end
  end
end
