class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  private
    def mail_to_user(user, **options)
      I18n.with_locale(user.preferred_locale.presence || I18n.default_locale) do
        mail(**options.merge(to: user.email_address))
      end
    end
end
