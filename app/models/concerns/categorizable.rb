module Categorizable

  included do
    has_many :categorizables, as: :categorizable, dependent: :destroy
    has_many :categories, through: :categorizables

    scope :in_category, ->(category_name) { joins(:categories).where(categories: {name: category_name}) }
    scope :in_categories, ->(category_names) { joins(:categories).where(categories: {name: category_names}).distinct }
  end

  def category_names
    categories.pluck(:name)
  end

  def category_names=(names)
    self.categories = names.reject(&:blank?).map do |name|
      Category.find_or_create_by(name: name.strip)
    end
  end

end
