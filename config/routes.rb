# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  match '/404', via: :all, to: 'errors#not_found'
  match '/422', via: :all, to: 'errors#unprocessable_entity'
  match '/500', via: :all, to: 'errors#server_error'
end
