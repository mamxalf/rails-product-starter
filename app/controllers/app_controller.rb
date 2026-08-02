class AppController < ApplicationController
  include VerifiedUserRequired
  include NotSuspended

  def show
  end
end
