class AuthenticateController < ApplicationController
  include Pundit
  after_action :verify_authorized

  class UnauthorizedError < StandardError; end

  # Pundit::NotAuthorizedError is explicitly in the doc a 403
  rescue_from Pundit::NotAuthorizedError, with: :user_not_allowed
  rescue_from UnauthorizedError, with: :user_not_authorized

  private

  def pundit_user
    @raw_jwt = retrieve_jwt_from_headers
    raise UnauthorizedError unless allowed?

    jwt.jwt_user
  end

  def user_not_authorized
    render json: 'Votre token n\'est pas valide ou n\'nest pas renseigné', status: 401
  end

  def user_not_allowed
    render json: 'Votre token est valide mais vos privilèges sont insuffisants', status: 403
  end

  def allowed?
    @raw_jwt && jwt.valid? && jwt.jwt_user
  end

  def jwt
    @jwt ||= JwtTokenService.new(jwt: @raw_jwt)
  end

  def retrieve_jwt_from_headers
    auth = request.headers['Authorization']
    if auth
      matchs = auth.match(/\ABearer (.+)\z/)
      matchs[1] if matchs
    end
  end
end
