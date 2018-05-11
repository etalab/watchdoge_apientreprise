class JwtTokenService
  include ActiveModel::Model

  attr_accessor :jwt

  validates_format_of :jwt, with: /\A([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)?\z/

  def jwt_user
    @jwt_user ||= decode_jwt
  end

  private

  def decode_jwt
    return nil unless valid? && decoded_token
    JwtUser.new(decoded_token)
  rescue JWT::DecodeError
    nil
  end

  def decoded_token
    @decoded_token ||= begin
      decoded_token = JWT.decode(@jwt, hash_secret, true, algorithm: hash_algo)
      decoded_token.map(&:deep_symbolize_keys!)
      decoded_token.first
    end
  end

  def hash_secret
    Rails.application.config_for(:secrets)['jwt_hash_secret']
  end

  def hash_algo
    Rails.application.config_for(:secrets)['jwt_hash_algo']
  end
end
