class Categorizable < ApplicationRecord
  belongs_to :category
  belongs_to :categorizable, polymorphic: true
end
