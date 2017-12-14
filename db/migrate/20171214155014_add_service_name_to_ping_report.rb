class AddServiceNameToPingReport < ActiveRecord::Migration[5.1]
  def change
    add_column :ping_reports, :service_name, :string
  end
end
