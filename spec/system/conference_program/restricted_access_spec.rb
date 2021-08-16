# frozen_string_literal: true

require "rails_helper"

describe "Conference restricted access", type: :system do
  let(:organization) { create :organization }
  let(:conference) { create(:conference, organization: organization) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
  let(:meeting) { create(:meeting, component: component) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:stubs) {}
  let(:setup) { meeting }
  let(:conference_conference_program_path) { decidim_conferences.conference_conference_program_path(conference, component) }

  before do
    setup
    stubs
    switch_to_host(organization.host)
    visit conference_conference_program_path
  end

  context "when conference program has RESTRICTED ACCESS" do
    let(:stubs) do
      stub_organization(:restricted_conference_program_access?, true)
    end

    context "when user is logged in" do
      let(:setup) do
        super()
        sign_in(user)
      end

      it "shows all the content" do
        expect(page).to have_css("#content > .extended.hero")
        expect(page).to have_css("#content > .row.expanded")
        expect(page).to have_css("#content > .wrapper")
      end

      context "when visiting another page belonging to the conference" do
        before do
          visit main_component_path(component) # meetings#index
        end

        it "does not show unauthorized error" do
          expect(page).not_to have_content("You are not authorized to perform this action")
        end
      end
    end

    context "when user is NOT logged in" do
      it "shows only the hero banner" do
        expect(page).to have_css("#content > .extended.hero")

        expect(page).not_to have_css("#content > .row.expanded")
        expect(page).not_to have_css("#content > .wrapper")
      end

      context "when visiting another page belonging to the conference" do
        before do
          visit main_component_path(component) # meetings#index
        end

        it "shows unauthorized error" do
          within_flash_messages do
            expect(page).to have_content("You are not authorized to perform this action")
          end
        end
      end
    end
  end

  context "when conference program does NOT have RESTRICTED ACCESS" do
    let(:stubs) do
      stub_organization(:restricted_conference_program_access?, false)
    end

    context "when user is logged in" do
      let(:setup) do
        super()
        sign_in(user)
      end

      it "shows all the content" do
        expect(page).to have_css("#content > .extended.hero")
        expect(page).to have_css("#content > .row.expanded")
        expect(page).to have_css("#content > .wrapper")
      end

      context "when visiting another page belonging to the conference" do
        before do
          visit main_component_path(component) # meetings#index
        end

        it "does not show unauthorized error" do
          expect(page).not_to have_content("You are not authorized to perform this action")
        end
      end
    end

    context "when user is NOT logged in" do
      it "shows all the content" do
        expect(page).to have_css("#content > .extended.hero")
        expect(page).to have_css("#content > .row.expanded")
        expect(page).to have_css("#content > .wrapper")
      end

      context "when visiting another page belonging to the conference" do
        before do
          visit main_component_path(component) # meetings#index
        end

        it "does not show unauthorized error" do
          expect(page).not_to have_content("You are not authorized to perform this action")
        end
      end
    end
  end
end
