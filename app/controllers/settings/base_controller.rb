module Settings
  class BaseController < ApplicationController
    include VerifiedUserRequired
    include NotSuspended

    layout "app"
    before_action :set_user

    private
      def set_user
        @user = Current.user
      end
  end
end
