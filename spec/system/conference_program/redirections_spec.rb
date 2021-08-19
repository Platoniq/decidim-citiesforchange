# frozen_string_literal: true

require "rails_helper"

describe "Conference program redirections", type: :system do
  let(:organization) { create :organization }
  let(:conference) { create(:conference, organization: organization) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space: conference) }
  let(:meeting) { create(:meeting, component: component) }
  let(:setup) {}
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

  describe "meetings page" do
    before do
      page.find("#conference-day-tab-0-label").click
      click_link translated(meeting.title)
    end

    let(:setup) do
      component.update(settings: { scopes_enabled: true })
      meeting.decidim_scope_id = scope.id
      meeting.category = category
      meeting.save
    end

    let(:scope) { create(:scope, organization: organization) }
    let(:category) { create(:category, participatory_space: conference) }

    context "when meetings index is set to REDIRECT to conference program" do
      let(:stubs) do
        super()
        stub_organization(:redirect_meetings_index_to_conference_program?, true)
      end

      context "when going back to list" do
        before do
          click_link "Back to list"
        end

        it "renders the program page" do
          expect(page).to have_current_path(/#{conference_conference_program_path}/i)
        end
      end

      context "when clicking on a category name" do
        before do
          click_link translated(category.name)
        end

        it "renders the program page" do
          expect(page).to have_current_path(/#{conference_conference_program_path}/i)
          expect(page).to have_current_path(/filter%5Bcategory_id%5D%5B%5D=#{category.id}/i)
        end
      end

      context "when clicking on a scope name" do
        before do
          click_link translated(scope.name)
        end

        it "renders the program page" do
          expect(page).to have_current_path(/#{conference_conference_program_path}/i)
          expect(page).to have_current_path(/filter%5Bscope_id%5D%5B%5D=#{scope.id}/i)
        end
      end
    end

    context "when meetings index is NOT set to REDIRECT to conference program" do
      let(:stubs) do
        super()
        stub_organization(:redirect_meetings_index_to_conference_program?, false)
      end

      context "when going back to list" do
        before do
          click_link "Back to list"
        end

        it "renders the meetings index" do
          expect(page).to have_current_path(/#{main_component_path(component)}/i)
        end
      end

      context "when clicking on a category name" do
        before do
          click_link translated(category.name)
        end

        it "renders the program page" do
          expect(page).to have_current_path(/#{main_component_path(component)}/i)
          expect(page).to have_current_path(/filter%5Bcategory_id%5D%5B%5D=#{category.id}/i)
        end
      end

      context "when clicking on a scope name" do
        before do
          click_link translated(scope.name)
        end

        it "renders the program page" do
          expect(page).to have_current_path(/#{main_component_path(component)}/i)
          expect(page).to have_current_path(/filter%5Bscope_id%5D%5B%5D=#{scope.id}/i)
        end
      end
    end
  end
end
