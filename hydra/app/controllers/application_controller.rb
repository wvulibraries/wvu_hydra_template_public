# Adds a few additional behaviors into the application controller
class ApplicationController < ActionController::Base
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  layout 'collection'

  protect_from_forgery with: :exception
  skip_after_action :discard_flash_if_xhr # don't keep the flash around for ajax requests
end
