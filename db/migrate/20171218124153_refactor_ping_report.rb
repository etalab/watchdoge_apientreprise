class RefactorPingReport < ActiveRecord::Migration[5.1]
  def change
    add_column :ping_reports, :uname, :string
    remove_column :ping_reports, :name, :string
    remove_column :ping_reports, :sub_name, :string
    remove_column :ping_reports, :service_name, :string
    remove_column :ping_reports, :api_version, :integer
  end
end
