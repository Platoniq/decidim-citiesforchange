# frozen_string_literal: true

require "rails_helper"

describe "Bulk invitations", type: :system do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:stubs) {}

  let(:submit_form) do
    within("#bulk-invitations form") do
      attach_file("CSV file", file_fixture(filename))
      select(csv_col_sep, from: "CSV column separator")
      select(bulk_invite_mode, from: "Bulk invite mode")
      find("*[type=submit]").click
    end
  end
  let(:filename) { "bulk_invitations/valid_file.csv" }
  let(:csv_col_sep) { "Semicolon" }
  let(:bulk_invite_mode) { "Send new invitations (ignores old users)" }

  before do
    stubs
    switch_to_host(organization.host)
    login_as(admin, scope: :user)
    visit(decidim_admin.root_path)
    click_link("Participants")
    within ".secondary-nav" do
      click_link "Participants"
    end
  end

  describe "form rendering" do
    context "when bulk invitations are enabled" do
      let(:stubs) do
        stub_organization(:bulk_invitations_enabled?, true)
      end

      it "renders the bulk invitations form" do
        expect(page).to have_css("#bulk-invitations form")
      end
    end

    context "when bulk invitations are NOT enabled" do
      let(:stubs) do
        stub_organization(:bulk_invitations_enabled?, false)
      end

      it "does not render the bulk invitations form" do
        expect(page).not_to have_css("#bulk-invitations form")
      end
    end
  end

  describe "form submission" do
    let(:stubs) do
      stub_organization(:bulk_invitations_enabled?, true)
    end

    context "when submitting without selecting a file" do
      before do
        within("#bulk-invitations form") do
          find("*[type=submit]").click
        end
      end

      it "does not submit the form" do
        within(".callout-wrapper") do
          expect(page).not_to have_content("The file was uploaded successfully")
          expect(page).not_to have_content("The file could not be uploaded")
        end
      end
    end

    context "when submitting an invalid CSV file" do
      before do
        submit_form
      end

      context "when headers are invalid" do
        let(:filename) { "bulk_invitations/invalid_headers.csv" }

        it "shows an error" do
          within(".callout-wrapper") do
            expect(page).to have_content("The file could not be uploaded because Csv file is invalid")
          end
        end
      end

      context "when extension are invalid" do
        let(:filename) { "bulk_invitations/invalid_extension.txt" }

        it "shows an error" do
          within(".callout-wrapper") do
            expect(page).to have_content("The file could not be uploaded because Csv file is invalid")
          end
        end
      end
    end

    context "when submitting a valid CSV file" do
      before do
        submit_form
      end

      context "when CSV column separator is invalid" do
        let(:csv_col_sep) { "Comma" }

        it "shows an error" do
          within(".callout-wrapper") do
            expect(page).to have_content("The file could not be uploaded because Csv file is invalid")
          end
        end
      end

      context "when CSV column separator is valid" do
        let(:csv_col_sep) { "Semicolon" }

        it "shows an error" do
          within(".callout-wrapper") do
            expect(page).to have_content("The file was uploaded successfully and processing will begin shortly")
          end
        end
      end
    end
  end

  describe "bulk invite mode" do
    let(:stubs) do
      stub_organization(:bulk_invitations_enabled?, true)
    end

    before do
      Decidim::User.where.not(id: admin.id).delete_all
    end

    context "when sending new invitations" do
      let(:bulk_invite_mode) { "Send new invitations (ignores old users)" }

      context "when submitting new data" do
        it "creates users" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.to change(Decidim::User, :count).by(4)
        end

        it "sends invitations" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.to change(ActionMailer::Base.deliveries, :count).by(4)
        end
      end

      context "when submitting old data" do
        before do
          perform_enqueued_jobs { submit_form }
        end

        it "does NOT create users" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.not_to change(Decidim::User, :count)
        end

        it "does NOT send invitations" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end
    end

    context "when resending old invitations" do
      let(:bulk_invite_mode) { "Resend old invitations (ignores new users)" }

      context "when submitting new data" do
        it "does NOT create users" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.not_to change(Decidim::User, :count)
        end

        it "does NOT send invitations" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end

      context "when submitting old data" do
        before do
          perform_enqueued_jobs { create_users }
        end

        let(:create_users) do
          different_bulk_invite_mode = "Send new invitations (ignores old users)"

          within("#bulk-invitations form") do
            attach_file("CSV file", file_fixture(filename))
            select(csv_col_sep, from: "CSV column separator")
            select(different_bulk_invite_mode, from: "Bulk invite mode")
            find("*[type=submit]").click
          end
        end

        it "does NOT create users" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.not_to change(Decidim::User, :count)
        end

        it "sends invitations" do
          expect do
            perform_enqueued_jobs { submit_form }
          end.to change(ActionMailer::Base.deliveries, :count).by(4)
        end
      end
    end
  end

  describe "invitation email" do
    let(:stubs) do
      stub_organization(:bulk_invitations_enabled?, true)
    end
    let(:last_email) { ActionMailer::Base.deliveries.last }

    before do
      perform_enqueued_jobs { submit_form }
    end

    it "sends invitation email" do
      expect(last_email.body.encoded).to include("/users/invitation/accept")
    end

    context "when following the email link and submitting the form" do
      before do
        logout(:user)
        visit(accept_invitation_url)
        submit_invitation_form
      end

      let(:accept_invitation_url) do
        text = last_email.text_part.decoded
        regex = %r{http://#{organization.host}/users/invitation/accept\?invitation_token=.+?(?=invite_redirect)}

        text.match(regex).to_s
      end
      let(:submit_invitation_form) do
        within("form#invitation_edit_user") do
          fill_in(:invitation_user_nickname, with: "el_duderino")
          fill_in(:invitation_user_password, with: "decidim123456")
          fill_in(:invitation_user_password_confirmation, with: "decidim123456")
          check(:invitation_user_tos_agreement)
          find("*[type=submit]").click
        end
      end

      it "logs the user and redirects to account page" do
        within(".flash.callout.success") do
          expect(page).to have_content("Your password was set successfully. You are now signed in.")
        end

        expect(page).to have_current_path(decidim.root_path)
      end
    end
  end
end
