class ProviderAvailabilitiesController < ApplicationController
  def index
    retrieve_dispo = ::Stats::TauxDisposFournisseursService.new(params[:endpoint], params[:period])
    retrieve_dispo.perform

    if retrieve_dispo.success?
      render json: retrieve_dispo.endpoint_availability, status: :ok
    else
      render json: { error: retrieve_dispo.error }, status: :unprocessable_entity
    end
  end
end
