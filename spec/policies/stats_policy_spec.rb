require 'rails_helper'

describe StatsPolicy do
  # need spec for action jwt_usage as it is always granted (only jwt integrity check)
  it_behaves_like 'jwt policy', :jwt_statistics, :admin_jwt_usage?
end
