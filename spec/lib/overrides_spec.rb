# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      # cells
      "/app/cells/decidim/content_blocks/highlighted_content_banner_cell.rb" => "690d34b533d26c9a6f81798fad95c013",
      "/app/cells/decidim/content_blocks/highlighted_content_banner/show.erb" => "3f6418d3ec970d7abe26bf1b2f012324",
      # layouts
      "/app/views/layouts/decidim/_head_extra.html.erb" => "1b8237357754cf519f4e418135f78440",
      "/app/views/layouts/decidim/_logo.html.erb" => "2713715db652c8107f1fe5f2c4d618b6",
      "/app/views/layouts/decidim/_mailer_logo.html.erb" => "8abb593b786423070101ded4ea8140b4",
      "/app/views/layouts/decidim/_mini_footer.html.erb" => "55a9ca723b65b8d9eadb714818a89bb3",
      "/app/views/layouts/decidim/_organization_colors.html.erb" => "34f0d188a62108e7a57a1c270daed8bb",
      # emails
      "/app/cells/decidim/newsletter_templates/image_text_cta/show.erb" => "bbdfded0065ce4c2ac93f6358853b887",
      "/app/cells/decidim/newsletter_templates/basic_only_text/show.erb" => "1f3020690377a48dd6bd1f75db3f2254"
    }
  },
  {
    package: "decidim-conferences",
    files: {
      # views
      "/app/views/decidim/conferences/conference_program/show.html.erb" => "e4d32ccc41adea7d9689b9021ef83694",
      "/app/views/decidim/conferences/conference_program/_program_meeting.html.erb" => "0b810b92d4a4fe7a47d19b73739b0494",
      "/app/views/layouts/decidim/_conference_hero.html.erb" => "80a466727d353089e21988a5c72e52bd"
    }
  },
  {
    package: "decidim-blogs",
    files: {
      # views
      "/app/views/decidim/blogs/posts/_posts.html.erb" => "59410d0eb3d64abea1e784475f86cebf",
      # cells
      "/app/cells/decidim/blogs/post_m_cell.rb" => "acf00828f5bca944ec03b9b188582e3d"
    }
  },
  {
    package: "decidim-admin",
    files: {
      # views
      "/app/views/decidim/admin/organization_appearance/form/_colors.html.erb" => "725fc77b4c80f885b7b4191a75a06949"
    }
  }
]

describe "Overriden files", type: :view do
  # rubocop:disable Rails/DynamicFindBy
  checksums.each do |item|
    spec = ::Gem::Specification.find_by_name(item[:package])

    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end
  # rubocop:enable Rails/DynamicFindBy

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
