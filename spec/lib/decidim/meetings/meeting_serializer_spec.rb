# frozen_string_literal: true

require "rails_helper"

describe Decidim::Meetings::MeetingSerializer do
  subject do
    described_class.new(meeting)
  end

  let(:meeting) { create(:meeting) }

  describe "#serialize" do
    let(:serialized) { subject.serialize }

    it "serializes the address" do
      expect(serialized).to include(address: meeting.address)
    end

    it "serializes the location" do
      expect(serialized).to include(location: meeting.location)
    end

    it "serializes the type_of_meeting" do
      expect(serialized).to include(type_of_meeting: meeting.type_of_meeting)
    end

    it "serializes the online_meeting_url" do
      expect(serialized).to include(online_meeting_url: meeting.online_meeting_url)
    end
  end
end
