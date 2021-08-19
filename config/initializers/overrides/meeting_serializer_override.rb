# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::MeetingSerializer.class_eval do
    alias_method :serialized, :serialize

    def serialize
      serialized.merge(extra_fields)
    end

    private

    def extra_fields
      {
        type_of_meeting: meeting.type_of_meeting,
        online_meeting_url: meeting.online_meeting_url
      }
    end
  end
end
