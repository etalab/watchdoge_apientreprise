class PingV2Job < ApplicationJob
  include HTTParty
  base_uri Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']

  def perform
    service_names.each do |service_name|
      ping = PingStatus.new(
        name: service_name,
        api_version: 2,
        status: get_service_status(service_name),
        date: DateTime.now
      )

      if ping.valid?
        Tools::PingReaderWriter.new.write(self)
        log(ping)
      else
        Rails.logger.error "Fail to write PingStatus(#{ping.name}) it's invalid (#{ping.errors.messages})"
      end
    end
  end

  private

  def get_service_status(service_name)
    response = perform_service(service_name)
    response.code == 200 ? 'up' : 'down'
  end

  def perform_service(service_name)
    self.class.get(
      "/v2/ping?token=#{apie_token}&service=#{service_name}"
    )
  end

  def log(ping)
    logger.info({
      endpoint: ping.name,
      status: ping.status,
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
