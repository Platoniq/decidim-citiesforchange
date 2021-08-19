# frozen_string_literal: true

require "rails_helper"
require "decidim/blogs/test/factories"
require "byebug"

describe "Visit the home page", type: :system, perform_enqueued: true do
  let(:organization) { create :organization }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when there are active content blocks" do
    let!(:participatory_space) { create(:participatory_process, organization: organization) }
    let!(:post_component) { create(:post_component, participatory_space: participatory_space) }
    let!(:meeting_component) { create(:meeting_component, participatory_space: participatory_space) }
    let!(:latest_blog_posts_block) { create(:content_block, organization: organization, manifest_name: :latest_blog_posts) }
    let!(:upcoming_meetings_block) { create(:content_block, organization: organization, manifest_name: :upcoming_meetings) }
    let!(:blog_post) { create(:post, component: post_component) }
    let!(:meeting) { create(:meeting, component: meeting_component) }

    let!(:blog_post_other) { create(:post) }
    let!(:meeting_other) { create(:meeting) }

    it "does not show content from other organizations" do
      visit decidim.root_path
      expect(page).to have_i18n_content(blog_post.title)
      expect(page).not_to have_i18n_content(blog_post_other.title)
      expect(page).to have_i18n_content(meeting.title)
      expect(page).not_to have_i18n_content(meeting_other.title)
    end
  end
end
