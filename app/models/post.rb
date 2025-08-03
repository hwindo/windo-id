class Post < ApplicationRecord
  include TaggableConcern
  include CategorizableConcern

  enum :status, { draft: 0, published: 1 }

  belongs_to :user
  has_rich_text :content
  has_one_attached :featured_image

  scope :recent, -> { order(created_at: :desc) }
end
