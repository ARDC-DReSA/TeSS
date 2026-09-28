# DReSA-specific (2026-09-28): optional metadata for educator tiles, mirroring
# the fields materials carry where they make sense for an AI educator -
# provider attribution, keywords, audience, licence and status.
class AddMetadataToEducators < ActiveRecord::Migration[7.0]
  def change
    add_column :educators, :content_provider_id, :integer
    add_index  :educators, :content_provider_id
    add_column :educators, :keywords, :string, array: true, default: []
    add_column :educators, :target_audience, :string, array: true, default: []
    add_column :educators, :licence, :string
    add_column :educators, :status, :string
  end
end
