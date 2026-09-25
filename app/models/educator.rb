# DReSA-specific model: a tile on the /educators page pointing at one of the
# AI educator applications (or any future guided-learning tool). Deliberately
# minimal - no search indexing, no materials/events associations - so it stays
# easy to re-apply on a fresh upstream fork.
class Educator < ApplicationRecord

  include HasFriendlyId

  belongs_to :user, optional: true

  auto_strip_attributes :title, :description, :url, :image_url, squish: false

  validates :title, :url, presence: true
  validates :url, url: true

  has_image(placeholder: TeSS::Config.placeholder['provider'])

  def self.visible_categories
    order(:created_at).group_by { |e| e.category.presence || 'Dataspaces' }
  end
end
