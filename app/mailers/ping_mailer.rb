class PingMailer < ApplicationMailer
  default from: 'ping.watchdoge@watchdoge.entreprise.api.gouv.fr'
  layout 'mailer'

  def ping(ping, endpoint)
    @ping = ping
    @endpoint = endpoint
    to = Rails.application.config_for(:secrets)['ping_email_recipient']
    subject = "[Watchdoge] V#{endpoint.api_version} #{ping.name} #{ping.status.upcase}"
    mail(to: to, subject: subject)
  end
end
