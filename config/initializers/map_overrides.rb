# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Meetings::MapHelper.class_eval do
    def meetings_data_for_map(meetings)
      geocoded_meetings = meetings.select(&:geocoded?)
      geocoded_meetings.map do |meeting|
        meeting.slice(:latitude, :longitude, :address).merge(title: translated_attribute(meeting.title),
                                                             description: html_truncate(sanitize(translated_attribute(meeting.description)), length: 200),
                                                             startTimeDay: l(meeting.start_time, format: "%d"),
                                                             startTimeMonth: l(meeting.start_time, format: "%B"),
                                                             startTimeYear: l(meeting.start_time, format: "%Y"),
                                                             startTime: "#{meeting.start_time.strftime("%H:%M")} - #{meeting.end_time.strftime("%H:%M")}",
                                                             icon: icon("meetings", width: 40, height: 70, remove_icon_class: true),
                                                             location: translated_attribute(meeting.location),
                                                             locationHints: decidim_html_escape(translated_attribute(meeting.location_hints)),
                                                             link: resource_locator(meeting).path)
      end
    end
  end

  Decidim::Meetings::Meeting.class_eval do
    def geocoded?
      latitude.present? && longitude.present? && !latitude.nan? && !longitude.nan?
    end
  end
end
