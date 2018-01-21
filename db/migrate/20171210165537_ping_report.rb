class PingReport < ActiveRecord::Migration[5.1]
  def change
    create_table :ping_reports do |t|
      t.string :uname
      t.integer :last_code
      t.timestamp :first_downtime
    end
  end
end
