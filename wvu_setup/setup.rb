#!/usr/bin/env ruby
require './generator/setup_import_files'
require './generator/setup_hydra_head'
require './generator/setup_model_file'
require './generator/setup_catalog_controller'

# to update the %%modelfile%%.rb file requires manual export from mfcs
# to to saved in the ./mfcs_export folder. Fields are dynamically generated
# from the mfcs_export.
SetupModelFile.new.perform

# update the import_helper.rb file requires manual export from mfcs
# to to saved in the ./mfcs_export folder. Fields are imported from
# the mfcs_export.
SetupImportFiles.new.perform

SetupCatalogController.new.perform

hydra = SetupHydraHead.new(
  model: 'Fsoc', # model name should be camel case example "TestCollection"
  collection:'Folk Songs of the Coalfields',
  page_description: 'test collection description', # collection description
  key_words: 'test collection keywords', # collection keywords for search  
  dev_host: 'http://localhost:3000', # development host
  prod_host: 'https://fsoc.lib.wvu.edu' # production host
)

hydra.perform


