Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'application#index'

  namespace :api do
    namespace :v1 do
      post 'command', to: 'commands#parse'
    end
  end

  get '*path', to: 'application#index', contraints: lambda { |req| 
    !req.xhr? && req.format.html?
  }
end
