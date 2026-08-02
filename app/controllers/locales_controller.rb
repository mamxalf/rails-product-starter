class LocalesController < ApplicationController
  allow_unauthenticated_access only: :update

  def update
    if available_locale?(params[:locale])
      authenticated? ? Current.user.update!(preferred_locale: params[:locale]) : cookies.signed.permanent[:locale] = params[:locale]
    end

    redirect_back_or_to new_session_path, status: :see_other
  end
end
