# frozen_string_literal: true

require "rails_helper"

describe "Conference program items", type: :system do
  let(:organization) { create :organization }
  let(:conference) { create(:conference, organization: organization) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
  let(:setup) do
    meeting_1
    meeting_2
  end
  let(:meeting_1) { create(:meeting, component: component) }
  let(:meeting_2) { create(:meeting, component: component) }
  let(:stubs) do
    stub_organization(:restricted_conference_program_access?, false)
  end
  let(:conference_conference_program_path) { decidim_conferences.conference_conference_program_path(conference, component) }

  before do
    setup
    stubs
    switch_to_host(organization.host)
    visit conference_conference_program_path
  end

  describe "location" do
    let(:setup) do
      super()
      meeting_1.update!(
        type_of_meeting: "online",
        online_meeting_url: "http://not.zoom/secret"
      )
      meeting_2.update!(
        type_of_meeting: "in_person",
        location: { en: "secret_location" },
        address: "secret_address",
        location_hints: { en: "secret_hints" }
      )
    end

    before do
      page.find("#conference-day-tab-0-label").click
    end

    it "renders only meetings for that month" do
      expect(page).to have_content translated(meeting_1.online_meeting_url)
      expect(page).to have_content translated(meeting_2.location)
      expect(page).to have_content translated(meeting_2.address)
      expect(page).to have_content translated(meeting_2.location_hints)
    end
  end
end
