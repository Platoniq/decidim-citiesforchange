# frozen_string_literal: true

require "rails_helper"

describe "Visit the conference programme page", type: :system, perform_enqueued: true do
  let!(:organization) { create :organization }
  let!(:conference) { create(:conference, organization: organization) }

  let!(:component) do
    create(:component, manifest_name: :meetings, participatory_space: conference)
  end

  # rubocop:disable Rails/TimeZone
  let!(:meeting_1) { create(:meeting, component: component, start_time: Time.new(2021, 12, 31, 14, 30), end_time: Time.new(2022, 12, 31, 18, 45)) }
  let!(:meeting_2) { create(:meeting, component: component, start_time: Time.new(2022, 0o3, 0o5, 14, 30), end_time: Time.new(2022, 0o3, 0o5, 18, 45)) }
  let!(:meeting_3) { create(:meeting, component: component, start_time: Time.new(2022, 0o3, 11, 14, 30), end_time: Time.new(2022, 0o3, 11, 18, 45)) }
  let!(:meeting_4) { create(:meeting, component: component, start_time: Time.new(2022, 0o5, 11, 14, 30), end_time: Time.new(2022, 0o5, 11, 18, 45)) }
  # rubocop:enable Rails/TimeZone

  before do
    switch_to_host(organization.host)
    visit decidim_conferences.conference_conference_program_path(conference, component)
  end

  it "renders the program page" do
    expect(page).to have_content(/Program/i)
  end

  it "renders tabs with month names and year" do
    within "#conference-day-tabs" do
      expect(page).to have_selector(".tabs-title", count: 3)
      expect(page).to have_content(/DECEMBER\n2021/i)
      expect(page).to have_content(/MARCH\n2022/i)
      expect(page).to have_content(/MAY\n2022/i)
    end
  end

  context "when clicking on a tab with a month name" do
    before do
      page.find("#conference-day-tab-1-label").click
    end

    it "renders only meetings for that month" do
      expect(page).to have_content translated(meeting_2.title)
      expect(page).to have_content translated(meeting_3.title)

      expect(page).not_to have_content translated(meeting_1.title)
      expect(page).not_to have_content translated(meeting_4.title)
    end
  end
end
