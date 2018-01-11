class CreateEndpoints < ActiveRecord::Migration[5.1]
  def change
    create_table :endpoints do |t|
      t.string :uname
      t.string :name
      t.string :api_name
      t.integer :api_version
      t.string :provider
      t.integer :ping_period
      t.string :http_path
      t.string :http_query
    end
  end
end
