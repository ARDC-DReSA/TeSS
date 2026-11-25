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

  has_image(placeholder: TeSS::Config.placeholder['content_provider'])

  # DRESA-96 (Nov 2026): the headings tiles are grouped under on /educators.
  # ARDC's own headings: only curators and admins may put a tile there.
  ARDC_HEADINGS = ['Dataspaces', 'FAIR (Findable, Accessible, Interoperable, Reusable)'].freeze
  # Headings anyone who may add a tile can choose (Rob's list, 25 Nov 2026).
  # To add a heading, add it here; the drop-down and the page order follow.
  OPEN_HEADINGS = ['Educators', 'Interactive modules', 'Guided modules',
                   'Learning Management System (LMS)', 'Cogniti'].freeze
  # Page order: ARDC headings first, then the open ones in the order above.
  HEADINGS = (ARDC_HEADINGS + OPEN_HEADINGS).freeze
  # A tile saved with no heading goes here (it used to fall under Dataspaces).
  DEFAULT_HEADING = 'Educators'.freeze
  # The database column itself defaults to 'Dataspaces' (from 2026). This line
  # makes new tiles start as 'Educators' instead, without a database change.
  attribute :category, :string, default: DEFAULT_HEADING

  before_validation { self.category = DEFAULT_HEADING if category.blank? }
  validates :category, inclusion: { in: HEADINGS, message: 'must be one of the headings in the list' }

  # True if this person may use ARDC's own headings.
  def self.ardc_heading_user?(user)
    user.present? && (user.is_admin? || user.is_curator?)
  end

  # The headings offered in the form's drop-down for this person. When editing,
  # the tile's current heading is always offered, so saving never moves it.
  def self.headings_for(user, current = nil)
    list = ardc_heading_user?(user) ? HEADINGS : OPEN_HEADINGS
    current.present? && !list.include?(current) ? [current] + list : list
  end

  # The heading this tile shows under on the page.
  def heading
    category.presence || DEFAULT_HEADING
  end

  # Tiles grouped by heading, headings in page order (a heading with no tiles
  # is simply not shown). Within a heading, oldest tile first.
  def self.visible_categories
    order(:created_at).group_by(&:heading).sort_by { |h, _| HEADINGS.index(h) || HEADINGS.size }
  end
end
