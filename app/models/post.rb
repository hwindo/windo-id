class Post < ApplicationRecord
  include Taggable
  include Categorizable
  
  enum :status, { draft: 0, published: 1 }

  belongs_to :user
  has_rich_text :content
  has_one_attached :featured_image
end
