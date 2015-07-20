class CreateFieldMappings < ActiveRecord::Migration
  def change
    create_table :field_mappings do |t|
      t.string :integration_field_name, null: false
      t.string :namely_field_name, null: false
      t.references(
        :attribute_mapper,
        foreign_key: true,
        index: true,
        null: false,
      )

      t.timestamps
    end
  end
end
