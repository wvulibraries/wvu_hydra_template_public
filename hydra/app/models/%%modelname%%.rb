# Generated Model for Metadata 
class %%modelname%% < ActiveFedora::Base
  include Hydra::AccessControls::Permissions

  # Minting ID
  # Overriding Fedoras LONG URI NOT FRIENDLY ID
  def assign_id
    identifier.gsub('.', '').to_s
  end  

  # insert fields here

  # end of insert fields

  # PROJECT IDENTIFIER
  # ==============================================================================================================
  # used in the search builder to target only records from this collection
  property :project, predicate: ::RDF::URI.intern('http://lib.wvu.edu/hydra/project'), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end  

  directly_contains :files, has_member_relation: ::RDF::URI('http://pcdm.org/models#File'), class_name: '%%modelname%%File'

  # image property
  directly_contains_one :image_file, through: :files, type: ::RDF::URI('http://pcdm.org/file-format-types#Image'),
                                     class_name: '%%modelname%%File'

  # thumbnail property
  directly_contains_one :thumbnail_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#ThumbnailImage'),
                                         class_name: '%%modelname%%File'

  # pdf property
  directly_contains_one :pdf_file, through: :files, type: ::RDF::URI('http://pcdm.org/file-format-types#Document'),
                                   class_name: '%%modelname%%File'

  # audio property
  directly_contains_one :audio_file, through: :files, type: ::RDF::URI('http://pcdm.org/file-format-types#Audio'),
                                     class_name: '%%modelname%%File'

  # video property
  directly_contains_one :video_file, through: :files, type: ::RDF::URI('http://pcdm.org/file-format-types#Video'),
                                     class_name: '%%modelname%%File'  
end
