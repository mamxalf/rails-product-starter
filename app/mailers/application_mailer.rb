class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "from@example.com")
  layout "mailer"

  private
    def mail_to_user(user, to: user.email_address, subject: nil, **options)
      I18n.with_locale(user.preferred_locale.presence || I18n.default_locale) do
        mail(**options.merge(to: to, subject: subject || t(".subject")))
      end
    end
end
