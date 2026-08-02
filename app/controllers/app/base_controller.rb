class App::BaseController < ApplicationController
  include VerifiedUserRequired
  include NotSuspended

  layout "inertia"

  inertia_share do
    user = Current.user

    {
      auth: {
        user: user && {
          id: user.id,
          name: user.name,
          email: user.email_address,
          role: user.role,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil
        }
      },
      locale: I18n.locale.to_s,
      permissions: {
        access_admin: user && UserPolicy.new(user, user).access_admin?
      },
      flash: {
        notice: flash[:notice],
        alert: flash[:alert]
      }
    }
  end
end
