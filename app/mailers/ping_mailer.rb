class PingMailer < ApplicationMailer
  default from: 'ping.watchdoge@watchdoge.entreprise.api.gouv.fr'
  layout 'mailer'

  def ping(ping_report)
    @ping_report = ping_report
    mail(to: to, subject: subject)
  end

  private

  def to
    Rails.application.config_for(:secrets)['ping_email_recipient']
  end

  def subject
    "[Watchdoge] V#{@ping_report.api_version} #{@ping_report.name} #{@ping_report.sub_name} #{@ping_report.status.upcase} à #{Time.now.strftime('%kh%M')}"
  end
end
