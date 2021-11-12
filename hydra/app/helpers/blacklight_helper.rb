module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    '%%collection%% | WVU Libraries'
  end
end