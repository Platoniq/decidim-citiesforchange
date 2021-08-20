# frozen_string_literal: true

require "rails_helper"

describe "Conference program filtering", type: :system, perform_enqueued: true do
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
  let(:meetings) do
    [
      meeting_1,
      meeting_2,
      meeting_3,
      meeting_4
    ]
  end
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:stubs) do
    stub_organization(:restricted_conference_program_access?, false)
  end
  let(:setup) { nil }
  let(:conference_conference_program_path) { decidim_conferences.conference_conference_program_path(conference, component) }

  before do
    stubs
    setup
    switch_to_host(organization.host)
    visit conference_conference_program_path
  end

  shared_examples "showing filtered program meetings" do
    it "shows only filtered meetings", :slow do
      expect(page).to have_content translated(filtered_meeting.title)

      meetings.without(filtered_meeting).each do |unfiltered_meeting|
        expect(page).not_to have_content translated(unfiltered_meeting.title)
      end
    end
  end

  shared_examples "filtering program meetings" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:filtered_conference_program_meetings?, true)
    end

    let(:unfiltered_meetings) { meetings.without(filtered_meeting) }

    context "when searching by TEXT" do
      before do
        within ".filters" do
          find(:css, "#content form.new_filter [name='filter[search_text]']").set(translated(meeting_2.title))
          find("#content form.new_filter .icon--magnifying-glass").click
        end
      end

      include_examples "showing filtered program meetings"
    end

    context "when filtering by TYPE" do
      let(:setup) do
        meeting_1.update(type_of_meeting: "online")
        meeting_2.update(type_of_meeting: "in_person")
        meeting_3.update(type_of_meeting: "online")
        meeting_4.update(type_of_meeting: "online")
      end

      before do
        within ".type_check_boxes_tree_filter" do
          uncheck "All"
          check "In-person"
        end
      end

      include_examples "showing filtered program meetings"
    end

    context "when filtering by SCOPE" do
      let(:setup) do
        meeting_2.update(decidim_scope_id: scope_1.id)
        meeting_3.update(decidim_scope_id: scope_2.id)
      end

      let(:scope_1) { create(:scope, organization: organization) }
      let(:scope_2) { create(:scope, organization: organization) }

      before do
        within ".scope_id_check_boxes_tree_filter" do
          uncheck "All"
          check translated(scope_1.name)
        end
      end

      it "shows custom legend" do
        within ".scope_id_check_boxes_tree_filter" do
          expect(page).to have_css("legend", text: "THEMATIC STREAM")
        end
      end

      include_examples "showing filtered program meetings"
    end

    context "when filtering by CATEGORY" do
      let(:setup) do
        meeting_2.category = category_1
        meeting_2.save
        meeting_3.category = category_2
        meeting_3.save
      end

      let(:category_1) { create(:category, participatory_space: conference) }
      let(:category_2) { create(:category, participatory_space: conference) }

      before do
        within ".category_id_check_boxes_tree_filter" do
          uncheck "All"
          check translated(category_1.name)
        end
      end

      it "shows custom legend" do
        within ".category_id_check_boxes_tree_filter" do
          expect(page).to have_css("legend", text: "SESSION TYPE")
        end
      end

      include_examples "showing filtered program meetings"
    end
  end

  context "when grouping by MONTH" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:conference_program_meetings_group_by, :month)
    end

    it "renders tabs with months" do
      within "#conference-day-tabs" do
        expect(page).to have_selector(".tabs-title", count: 3)
        expect(page).to have_content(/DECEMBER\n2021/i)
        expect(page).to have_content(/MARCH\n2022/i)
        expect(page).to have_content(/MAY\n2022/i)
      end
    end

    context "when clicking on a tab with a month" do
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

    it_behaves_like "filtering program meetings" do
      before do
        page.find("#conference-day-tab-1-label").click
      end

      let(:filtered_meeting) { meeting_2 }
    end
  end

  context "when grouping by DAY" do
    let(:stubs) do
      super() # run stubs from parent context
      stub_organization(:conference_program_meetings_group_by, :day)
    end

    it "renders tabs with days" do
      within "#conference-day-tabs" do
        expect(page).to have_selector(".tabs-title", count: 4)
        expect(page).to have_content(/Fri 31/i)
        expect(page).to have_content(/Sat 05/i)
        expect(page).to have_content(/Fri 11/i)
        expect(page).to have_content(/Wed 11/i)
      end
    end

    context "when clicking on a tab with a day" do
      before do
        page.find("#conference-day-tab-1-label").click
      end

      it "renders only meetings for that day" do
        expect(page).to have_content translated(meeting_2.title)

        expect(page).not_to have_content translated(meeting_3.title)
        expect(page).not_to have_content translated(meeting_1.title)
        expect(page).not_to have_content translated(meeting_4.title)
      end
    end

    it_behaves_like "filtering program meetings" do
      before do
        page.find("#conference-day-tab-1-label").click
      end

      let(:filtered_meeting) { meeting_2 }
    end
  end
end