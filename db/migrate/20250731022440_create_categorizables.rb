class CreateCategorizables < ActiveRecord::Migration[8.0]
  def change
    create_table :categorizables do |t|
      t.references :category, null: false, foreign_key: true
      t.references :categorizable, null: false, foreign_key: true

      t.timestamps

      add_index :categorizables, [ :category_id, :categorizable_type, :categorizable_id ], unique: true, name: index_categorizables_on_category_and_categorizable
    end
  end
end
