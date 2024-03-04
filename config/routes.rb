Rails.application.routes.draw do
  resources :nodes, path: '/', only: [] do
    collection do
      get :lowest_common_ancestor
      get :birds
    end
  end
end
