class CreateAttributeMappers < ActiveRecord::Migration
  def change
    create_table :attribute_mappers do |t|
      t.string :mapping_direction, null: false
      t.references :user, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
