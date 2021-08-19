# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount Decidim::Core::Engine => "/"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope module: "decidim" do
    namespace :admin do
      scope module: "bulk_invitations" do
        resources :bulk_invitations, only: [:new, :create]
      end
    end
  end
end
