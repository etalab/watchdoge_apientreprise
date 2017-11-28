class Endpoints::APIEHomepage < Endpoint
  def initialize
    super
    @name = 'homepage'
    @provider = 'apie'
    @api_version = 2
    @api_name = 'apie'
    @period = 1
    @parameter = 'homepage'
    @options = { recipient: 'SGMAP', context: 'Ping' }
    @specific_url = endpoint_specific_url
  end

  private

  def endpoint_specific_url
    "/?#{@options.to_param}"
  end
end
