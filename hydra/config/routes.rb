Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new
  
  # images
  get 'image/:id'  => 'image_viewer#index'
  get 'thumb/:id'  => 'image_viewer#thumb'

  get 'audio/:id' => 'audio_player#index'
  get 'video/:id' => 'video_player#index'
  get 'pdf/:id' => 'pdf_viewer#index'

  # redirect
  # get 'record/:id' => 'record#index'
  get '/record/:id', to: redirect('/catalog/%{id}')

  # pages
  get '/about' => 'catalog#about'
  
  mount Blacklight::Engine => '/'
  root to: 'catalog#index'
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider
    concerns :searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
