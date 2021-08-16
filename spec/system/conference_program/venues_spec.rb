# frozen_string_literal: true

require "rails_helper"

describe "Conference venues", type: :system do
  let(:organization) { create :organization }
  let(:conference) { create(:conference, organization: organization) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
  let(:meeting) { create(:meeting, component: component) }
  let(:setup) do
    meeting
    conference.update(show_statistics: false)
  end
  let(:stubs) do
    stub_organization(:restricted_conference_program_access?, false)
  end
  let(:conference_conference_program_path) { decidim_conferences.conference_conference_program_path(conference, component) }

  before do
    setup
    stubs
    switch_to_host(organization.host)
    visit conference_conference_program_path
    within "#process-nav-content" do
      click_link("Venues")
    end
  end

  context "when in degrowth instance" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:degrowth?, true)
    end

    it "renders expected sections" do
      within ".wrapper" do
        expect(page).to have_css("section#venues")

        expect(page).not_to have_css("h3", text: "INTRODUCTION")
        expect(page).not_to have_css("h3", text: "DETAILS")
        expect(page).not_to have_link(translated(component.name), href: conference_conference_program_path)
      end
    end
  end

  context "when in citiesforchange instance" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:citiesforchange?, true)
    end

    it "renders expected sections" do
      within ".wrapper" do
        expect(page).to have_css("h3", text: "INTRODUCTION")
        expect(page).to have_css("h3", text: "DETAILS")
        expect(page).to have_link(translated(component.name), href: conference_conference_program_path)
        expect(page).to have_css("section#venues")
      end
    end
  end
end
