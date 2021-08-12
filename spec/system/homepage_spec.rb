# frozen_string_literal: true

require "rails_helper"
require "byebug"

describe "Visit the home page", type: :system, perform_enqueued: true do
  let(:organization) { create :organization }
  let(:stubs) { nil }

  before do
    stubs
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the home page" do
    expect(page).to have_content("Home")
  end

  describe "sign up button" do
    shared_context "with sign up enabled" do
      let(:stubs) do
        super() # run stubs from parent context
        stub_organization(:sign_up_enabled?, true)
      end
    end

    shared_context "with sign up disabled" do
      let(:stubs) do
        super() # run stubs from parent context
        stub_organization(:sign_up_enabled?, false)
      end
    end

    context "when in degrowth instance" do
      let(:stubs) do
        stub_organization(:degrowth?, true)
      end

      context "when sign up is disabled" do
        include_context "with sign up disabled"

        it "renders expected button" do
          within ".title-bar" do
            expect(page).to have_link("Register", href: Rails.application.secrets.degrowth[:register_url])

            expect(page).not_to have_link("Sign Up", href: decidim.new_user_registration_path)
          end
        end
      end

      context "when sign up is enabled" do
        include_context "with sign up enabled"

        it "shows regular sign up button" do
          within ".title-bar" do
            expect(page).to have_link("Sign Up", href: decidim.new_user_registration_path)

            expect(page).not_to have_link("Register", href: Rails.application.secrets.degrowth[:register_url])
          end
        end
      end
    end

    context "when in citiesforchange instance" do
      let(:stubs) do
        stub_organization(:citiesforchange?, true)
      end

      context "when sign up is disabled" do
        include_context "with sign up disabled"

        it "renders expected button" do
          within ".title-bar" do
            expect(page).not_to have_link("Sign Up", href: decidim.new_user_registration_path)
            expect(page).not_to have_link("Register", href: Rails.application.secrets.degrowth[:register_url])
          end
        end
      end

      context "when sign up is enabled" do
        include_context "with sign up enabled"

        it "shows regular sign up button" do
          within ".title-bar" do
            expect(page).to have_link("Sign Up", href: decidim.new_user_registration_path)

            expect(page).not_to have_link("Register", href: Rails.application.secrets.degrowth[:register_url])
          end
        end
      end
    end
  end

  # it "has matomo tracker" do
  #   expect(page.execute_script("return typeof window._paq")).not_to eq("undefined")
  #   expect(page.execute_script("return typeof window._paq")).to eq("object")
  # end
end
