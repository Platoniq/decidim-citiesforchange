# frozen_string_literal: true

require "rails_helper"

module Decidim::Conferences
  describe ConferenceProgramMeetingsByMonth do
    subject { described_class.new(component, month, user) }

    let(:conference) { create(:conference) }

    let(:component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let!(:meeting_1) { create(:meeting, component: component, start_time: 1.month.from_now.beginning_of_month + 7.days, end_time: 1.month.from_now.beginning_of_month + 14.days) }
    let!(:meeting_2) { create(:meeting, component: component, start_time: 1.month.from_now.beginning_of_month, end_time: 1.month.from_now.beginning_of_month + 14.days) }
    let!(:meeting_3) { create(:meeting, component: component, start_time: 3.months.from_now.beginning_of_month, end_time: 3.months.from_now.beginning_of_month + 14.days) }
    let!(:month) { meeting_1.start_time.to_date }

    describe "query" do
      let(:user) { nil }

      it "includes the meetings in the date range" do
        expect(subject.to_a).to eq [
          meeting_2,
          meeting_1
        ]
      end

      it "excludes the meetings not in the date range" do
        expect(subject).not_to include(*meeting_3)
      end
    end
  end
end
