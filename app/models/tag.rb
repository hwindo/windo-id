class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { name_changed? }
  scope :by_name, -> { order(:name) }
  scope :recent, -> { where("created_at >= ?", 1.week.ago) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
