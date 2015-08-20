class CreateInstallations < ActiveRecord::Migration
  def up
    create_table :installations do |t|
      t.string :subdomain, null: false

      t.timestamps null: false
    end

    add_index :installations, :subdomain, unique: true

    insert(<<-SQL)
      INSERT INTO installations
        (subdomain, created_at, updated_at)
      SELECT DISTINCT
        subdomain, #{now}, #{now}
      FROM users
    SQL
  end

  def down
    drop_table :installations
  end

  private

  def now
    "'#{Time.now.to_s(:db)}' :: timestamp"
  end
end
