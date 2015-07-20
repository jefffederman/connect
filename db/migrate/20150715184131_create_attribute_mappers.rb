class CreateAttributeMappers < ActiveRecord::Migration
  def change
    create_table :attribute_mappers do |table|
      table.string :mapping_direction, null: false
      table.references :user, null: false, foreign_key: true, index: true

      table.timestamps null: false
    end
  end
end
