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
      "/app/views/devise/mailer/confirmation_instructions.html.erb" => "0294dc0647c90df728c943c4dd907b2b",
      "/app/views/devise/mailer/invitation_instructions.html.erb" => "094174f490539e4b21d530efce951c2f",
      "/app/views/devise/mailer/invite_admin.html.erb" => "341a5c55b73404a5029e8e2504f6a977",
      "/app/views/devise/mailer/invite_collaborator.html.erb" => "341a5c55b73404a5029e8e2504f6a977",
      "/app/views/devise/mailer/invite_private_user.html.erb" => "34dcde934dce62337fc6e8370ee428d4",
      "/app/views/devise/mailer/organization_admin_invitation_instructions.html.erb" => "3d4bd7c8e6848da314e6a0d7d2f173ae",
      "/app/views/devise/mailer/password_change.html.erb" => "3f9126fcf201a5c6bba12d5ab6461bde",
      "/app/views/devise/mailer/reset_password_instructions.html.erb" => "6a74be33a8c03a934eaa51e89b9f8218",
      "/app/views/devise/mailer/unlock_instructions.html.erb" => "dce82d19fa2aba81e4e5dfd8b8125938",
    }
  },
  {
    package: "decidim-conferences",
    files: {
      # views
      "/app/views/decidim/conferences/conference_program/show.html.erb" => "e4d32ccc41adea7d9689b9021ef83694",
      "/app/views/decidim/conferences/conference_program/_program_meeting.html.erb" => "0b810b92d4a4fe7a47d19b73739b0494",
      # emails
      "/app/views/devise/mailer/join_conference.html.erb" => "d4952e1e5243893a8efc78efc4ec33aa"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      # emails
      "/app/views/devise/mailer/join_meeting.html.erb" => "250f7ba6b1c7f01555e3e3eb317faa44"
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
