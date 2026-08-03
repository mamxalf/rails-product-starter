class App::BaseController < ApplicationController
  include VerifiedUserRequired
  include NotSuspended

  layout "app"
end
