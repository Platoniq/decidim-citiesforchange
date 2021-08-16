# frozen_string_literal: true

require "rails_helper"

describe "Conference hero banner", type: :system do
  include Decidim::Conferences::ConferenceHelper
  include ActionView::Helpers::TranslationHelper

  let(:organization) { create :organization }
  let(:conference) { create(:conference, organization: organization) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
  let(:meeting) { create(:meeting, component: component) }
  let(:stubs) {}
  let(:conference_conference_program_path) { decidim_conferences.conference_conference_program_path(conference, component) }

  before do
    meeting
    stubs
    switch_to_host(organization.host)
    visit conference_conference_program_path
  end

  context "when in degrowth instance" do
    let(:stubs) do
      stub_organization(:degrowth?, true)
    end

    it "renders expected hero banner" do
      within "#content > .extended.hero" do
        expect(page).to have_css("h1", text: translated(conference.slogan))
        expect(page).to have_css("a[href='#{Rails.application.secrets.degrowth[:pdf_program_url]}'][target='_blank']", text: "PROGRAM (PDF)")

        expect(page).not_to have_css("h1", text: translated(conference.title))
        expect(page).not_to have_css("h2", text: translated(conference.slogan))
        expect(page).not_to have_content(render_date(conference))
        expect(page).not_to have_content(conference.location)
        expect(page).not_to have_link(translated(component.name), href: conference_conference_program_path)
      end
    end
  end

  context "when in citiesforchange instance" do
    let(:stubs) do
      stub_organization(:citiesforchange?, true)
    end

    it "renders expected hero banner" do
      within "#content > .extended.hero" do
        expect(page).to have_css("h1", text: translated(conference.title))
        expect(page).to have_css("h2", text: translated(conference.slogan))
        expect(page).to have_content(render_date(conference))
        expect(page).to have_content(conference.location)
        expect(page).to have_link(translated(component.name), href: conference_conference_program_path)

        expect(page).not_to have_css("h1", text: translated(conference.slogan))
        expect(page).not_to have_css("a[href='#{Rails.application.secrets.degrowth[:pdf_program_url]}'][target='_blank']", text: "PROGRAM (PDF)")
      end
    end
  end
end
