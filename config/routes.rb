Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'tests/teset'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'application#index'

  namespace :api do
    namespace :v1 do
      get 'test', to: 'tests#teset'
    end
  end

  get '*path', to: 'application#index', contraints: lambda { |req| 
    !req.xhr? && req.format.html?
  }
end
