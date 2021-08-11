# frozen_string_literal: true

Decidim::Organization.class_eval do
  def instance_name
    if citiesforchange?
      :citiesforchange
    elsif degrowth?
      :degrowth
    end
  end

  def instance_prefix_path(path)
    if citiesforchange?
      path
    else
      "#{instance_name}/#{path}"
    end
  end

  def citiesforchange?
    host.match?("citiesforchange")
  end

  def degrowth?
    host.match?("degrowth") || host.match?("localhost") # DEBUG
  end

  def filtered_conference_program_meetings?
    degrowth?
  end
end
