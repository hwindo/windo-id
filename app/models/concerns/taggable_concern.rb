module TaggableConcern
  extend ActiveSupport::Concern

  included do
    has_many :taggables, as: :taggable, dependent: :destroy
        has_many :tags, through: :taggables

    scope :tagged_with, ->(tag_name) { joins(:tags).where(tags: { name: tag_name }) }
    scope :tagged_with_any, ->(tag_name) { joins(:tags).where(tags: { name: tag_name }).distinct }
  end

  def tag_names
    tags.pluck(:name)
  end

  def tag_names=(names)
    names = names.is_a?(String) ? names.split(",") : names
    self.tags = names.reject(&:blank?).map do |name|
      Tag.find_or_create_by(name: name.strip)
    end
  end
end
