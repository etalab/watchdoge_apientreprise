require 'rails_helper'

describe StatsPolicy do
  it_behaves_like 'jwt policy', :jwt_statistics, :jwt_usage?
end
