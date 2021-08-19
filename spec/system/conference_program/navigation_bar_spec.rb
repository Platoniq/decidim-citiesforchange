# frozen_string_literal: true

require "rails_helper"

describe "Conference navigation bar", type: :system do
  let(:organization) { create :organization }
  let(:conference) { create(:conference, organization: organization) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
  let(:meeting) { create(:meeting, component: component) }
  let(:speaker) { create(:conference_speaker, conference: conference) }
  let(:stubs) do
    stub_organization(:restricted_conference_program_access?, false)
  end
  let(:conference_conference_program_path) { decidim_conferences.conference_conference_program_path(conference, component) }

  before do
    meeting
    speaker
    stubs
    switch_to_host(organization.host)
    visit conference_conference_program_path
  end

  context "when in degrowth instance" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:degrowth?, true)
    end

    it "renders expected navigation bar" do
      within "#process-nav-content" do
        links = find_all("a")

        expect(links.size).to eq(3)
        expect(links[0].text).to eq(translated(component.name).upcase)
        expect(links[1].text).to eq("SPEAKERS")
        expect(links[2].text).to eq("VENUES")
        expect(links[2].matches_css?("a[href='#{decidim_conferences.conference_path(conference)}']")).to eq(true)
      end
    end
  end

  context "when in citiesforchange instance" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:citiesforchange?, true)
    end

    it "renders expected navigation bar" do
      within "#process-nav-content" do
        links = find_all("a")

        expect(links.size).to eq(4)
        expect(links[0].text).to eq("INFORMATION")
        expect(links[1].text).to eq("SPEAKERS")
        expect(links[2].text).to eq(translated(component.name).upcase)
        expect(links[3].text).to eq("VENUES")
        expect(links[3].matches_css?("a[href='#{decidim_conferences.conference_path(conference)}#venues']")).to eq(true)
      end
    end
  end
end
