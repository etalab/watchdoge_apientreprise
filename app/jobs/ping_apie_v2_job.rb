class PingAPIEV2Job < ApplicationJob
  include HTTParty
  base_uri Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']

  def perform
    service_names.each do |service_name|
      status = perform_service(service_name)
      ping = PingStatus.new(name: service_name, code: status, date: DateTime.now)

      if ping.valid?
        ping.save
        log(ping)
      end
    end
  end

  private

  def perform_service(service_name)
    self.class.get(
      "/v2/ping?token=#{apie_token}&service=#{service_name}"
    )
  end

  def log(ping)
    logger.info({
      endpoint: ping.name,
      code: ping.code,
      date: ping.date
    })
  end

  def apie_token
    Rails.application.config_for(:watchdoge_secrets)['apie_token']
  end

  def service_names
    %w(
    insee_etablissement
    insee_entreprise
    )
  end
end
