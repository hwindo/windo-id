class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug, null: false
      t.timestamps

      add_index :categories, :name, unique: true
      add_index :categories, :slug, unique: true
    end
  end
end
