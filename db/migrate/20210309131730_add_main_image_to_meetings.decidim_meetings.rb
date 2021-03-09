# frozen_string_literal: true
# This migration comes from decidim_meetings (originally 20210303114850)

class AddMainImageToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :main_image, :string
  end
end
