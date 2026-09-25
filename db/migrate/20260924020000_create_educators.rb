# DReSA-specific: AI educator tiles (the /educators page).
# NOTE for the future upstream re-fork: this is DReSA's first custom migration -
# it must be re-applied (or replaced with upstream "spaces"/learning features)
# when DReSA moves to a fresh fork of upstream TeSS.
class CreateEducators < ActiveRecord::Migration[5.2]
  def change
    create_table :educators do |t|
      t.text :title, null: false
      t.text :url, null: false
      t.text :description
      t.text :image_url
      t.string :category, default: 'Dataspaces'
      t.string :slug
      t.integer :user_id
      # paperclip attachment columns (matches content_providers)
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
    add_index :educators, :slug, unique: true
    add_index :educators, :user_id
  end
end
