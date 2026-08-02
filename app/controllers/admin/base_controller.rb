module Admin
  class BaseController < ApplicationController
    include VerifiedUserRequired
    include NotSuspended

    layout "admin"
    before_action :authorize_admin

    private
      def authorize_admin
        authorize Current.user, :access_admin?
      end
  end
end
