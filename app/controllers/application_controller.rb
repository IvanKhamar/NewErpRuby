# Base of the HTML admin pages. The JSON API has its own base (Api::V1::BaseController).
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes
end
