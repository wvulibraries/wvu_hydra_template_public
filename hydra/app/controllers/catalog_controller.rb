# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  include Hydra::Catalog
  include BlacklightOaiProvider::Controller
  # This filter applies the hydra access controls
  # before_action :enforce_show_permissions, only: :show

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository

    ## OAIPMH
    config.oai = {
      provider: {
        repository_name: '%%collection%%',
        repository_url: '%%prod_host%%/catalog/oai',
        record_prefix: '%%prod_host%%/catalog/',
        admin_email: 'libsys@mail.wvu.edu'
      },
      document: {
        limit: 25,
        set_fields: [
          { label: 'language', solr_field: 'language_facet' }
        ]
      }
    }
    
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    config.search_builder_class = ::SearchBuilder

    # Turn off SMS, Email, Citation
    config.show.document_actions.delete(:sms)
    config.show.document_actions.delete(:citation)

    # search config
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'

    # facet creator 
    config.add_facet_field solr_name('{{solr_name}}', :facetable), :label => '{{solr_name}}', :limit => 10

    # uses the above facets in blacklight
    config.default_solr_params['facet.field'] = config.facet_fields.keys
    
    # The ordering of the field names is the order of the display
    config.add_index_field solr_name('identifier', :stored_searchable, type: :string), :label => 'Identifier'

    # show fields in the objects 
    # order is by the order you put them in 
    config.add_show_field solr_name('identifier', :stored_searchable, type: :string), :label => 'Identifier'

    # search fields  
    config.add_search_field 'all_fields', label: 'All Fields'

    # add the search fields individually from solr 
    # use this as a template for creating new ones 
    config.add_search_field('identifier') do |field|
      identifier_field = Solrizer.solr_name("identifier", :stored_searchable)
      field.solr_local_parameters = {
        qf: identifier_field,
        pf: identifier_field
      }
    end

    # sorting results should be custom to each collection
    sort_title = Solrizer.solr_name('title', :stored_sortable, type: :string)
    sort_creator = Solrizer.solr_name('creator', :stored_sortable, type: :string)
    sort_identifier = Solrizer.solr_name('identifier', :stored_sortable, type: :string)

    config.add_sort_field "#{sort_identifier} asc", :label => 'Identifier (asc)'
    config.add_sort_field "#{sort_identifier} desc", :label => 'Identifier (desc)'
    config.add_sort_field "#{sort_title} asc", :label => 'Title (A-Z)'
    config.add_sort_field "#{sort_title} desc", :label => 'Title (Z-A)'
    config.add_sort_field "#{sort_creator} asc", :label => 'Creator (A-Z)'
    config.add_sort_field "#{sort_creator} desc", :label => 'Creator (Z-A)'
    config.add_sort_field "score desc, #{sort_identifier} asc", :label => 'Relevance'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # adds additional pages that will also use the searchbar from the navigation 
  # customizable behavior should be done in a module or static model 
  def about
    render "about.html.erb"
  end
end