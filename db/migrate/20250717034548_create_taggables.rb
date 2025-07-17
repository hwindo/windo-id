class CreateTaggables < ActiveRecord::Migration[8.0]
  def change
    create_table :taggables do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :taggables, [ :tag_id, :taggable_type, :taggable_id ],
      unique: true, 
      name: "index_taggable_on_tag_and_taggable"
  end
end
