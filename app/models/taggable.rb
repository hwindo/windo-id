class Taggable < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
