# Polymorphic Tagging & Category System Implementation Plan

This document outlines the complete implementation plan for adding polymorphic tags and categories to the blog and portfolio system.

## Overview

The system will support:
- **Tags**: Flexible labeling system for both blog posts and portfolio items
- **Categories**: Hierarchical organization for content classification
- **Polymorphic associations**: Same tag/category can be applied to different model types
- **Future extensibility**: Easy to add tagging to new models

## Step 1: Create Tag Model and Migration

### Generate Tag Model
```bash
bin/rails generate model Tag name:string slug:string
```

### Edit Tag Migration
```ruby
# db/migrate/xxx_create_tags.rb
class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    
    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true
  end
end
```

### Update Tag Model
```ruby
# app/models/tag.rb
class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: :name_changed?
  
  scope :by_name, -> { order(:name) }
  
  def to_param
    slug
  end
  
  private
  
  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
```

## Step 2: Create Category Model

### Generate Category Model
```bash
bin/rails generate model Category name:string description:text slug:string
```

### Edit Category Migration
```ruby
# db/migrate/xxx_create_categories.rb
class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug, null: false
      t.timestamps
    end
    
    add_index :categories, :name, unique: true
    add_index :categories, :slug, unique: true
  end
end
```

### Update Category Model
```ruby
# app/models/category.rb
class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: :name_changed?
  
  scope :by_name, -> { order(:name) }
  
  def to_param
    slug
  end
  
  private
  
  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
```

## Step 3: Create Polymorphic Join Tables

### Generate Join Models
```bash
bin/rails generate model Taggable tag:references taggable:references{polymorphic}
bin/rails generate model Categorizable category:references categorizable:references{polymorphic}
```

### Edit Taggable Migration
```ruby
# db/migrate/xxx_create_taggables.rb
class CreateTaggables < ActiveRecord::Migration[8.0]
  def change
    create_table :taggables do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.timestamps
    end
    
    add_index :taggables, [:tag_id, :taggable_type, :taggable_id], unique: true, name: 'index_taggables_on_tag_and_taggable'
  end
end
```

### Edit Categorizable Migration
```ruby
# db/migrate/xxx_create_categorizables.rb
class CreateCategorizables < ActiveRecord::Migration[8.0]
  def change
    create_table :categorizables do |t|
      t.references :category, null: false, foreign_key: true
      t.references :categorizable, polymorphic: true, null: false
      t.timestamps
    end
    
    add_index :categorizables, [:category_id, :categorizable_type, :categorizable_id], unique: true, name: 'index_categorizables_on_category_and_categorizable'
  end
end
```

## Step 4: Create Concerns

### Create Taggable Concern
```ruby
# app/models/concerns/taggable.rb
module Taggable
  extend ActiveSupport::Concern
  
  included do
    has_many :taggables, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggables
    
    scope :tagged_with, ->(tag_name) { joins(:tags).where(tags: { name: tag_name }) }
    scope :tagged_with_any, ->(tag_names) { joins(:tags).where(tags: { name: tag_names }).distinct }
  end
  
  def tag_names
    tags.pluck(:name)
  end
  
  def tag_names=(names)
    self.tags = names.reject(&:blank?).map do |name|
      Tag.find_or_create_by(name: name.strip)
    end
  end
end
```

### Create Categorizable Concern
```ruby
# app/models/concerns/categorizable.rb
module Categorizable
  extend ActiveSupport::Concern
  
  included do
    has_many :categorizables, as: :categorizable, dependent: :destroy
    has_many :categories, through: :categorizables
    
    scope :in_category, ->(category_name) { joins(:categories).where(categories: { name: category_name }) }
    scope :in_categories, ->(category_names) { joins(:categories).where(categories: { name: category_names }).distinct }
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
```

## Step 5: Update Models

### Update Post Model
```ruby
# app/models/post.rb
class Post < ApplicationRecord
  include Taggable
  include Categorizable
  
  enum :status, { draft: 0, published: 1 }

  belongs_to :user
  has_rich_text :content
  has_one_attached :featured_image
end
```

### Update Join Models
```ruby
# app/models/taggable.rb
class Taggable < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
```

```ruby
# app/models/categorizable.rb
class Categorizable < ApplicationRecord
  belongs_to :category
  belongs_to :categorizable, polymorphic: true
end
```

## Step 6: Run Migrations
```bash
bin/rails db:migrate
```

## Step 7: Update Controllers

### Update PostsController
```ruby
# app/controllers/posts_controller.rb
# Add to post_params method:
def post_params
  params.require(:post).permit(:title, :content, :featured_image, :status, 
                               tag_names: [], category_names: [])
end
```

### Create TagsController (Admin)
```ruby
# app/controllers/tags_controller.rb
class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  
  def index
    @tags = Tag.by_name.includes(:taggables)
  end
  
  def show
    @posts = Post.tagged_with(@tag.name).published.order(created_at: :desc)
  end
  
  def new
    @tag = Tag.new
  end
  
  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to tags_path, notice: 'Tag created successfully.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @tag.update(tag_params)
      redirect_to tags_path, notice: 'Tag updated successfully.'
    else
      render :edit
    end
  end
  
  def destroy
    @tag.destroy
    redirect_to tags_path, notice: 'Tag deleted successfully.'
  end
  
  private
  
  def set_tag
    @tag = Tag.find_by!(slug: params[:id])
  end
  
  def tag_params
    params.require(:tag).permit(:name)
  end
end
```

### Create CategoriesController (Admin)
```ruby
# app/controllers/categories_controller.rb
class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  
  def index
    @categories = Category.by_name.includes(:categorizables)
  end
  
  def show
    @posts = Post.in_category(@category.name).published.order(created_at: :desc)
  end
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: 'Category created successfully.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'Category updated successfully.'
    else
      render :edit
    end
  end
  
  def destroy
    @category.destroy
    redirect_to categories_path, notice: 'Category deleted successfully.'
  end
  
  private
  
  def set_category
    @category = Category.find_by!(slug: params[:id])
  end
  
  def category_params
    params.require(:category).permit(:name, :description)
  end
end
```

## Step 8: Update Routes

### Add to routes.rb
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ... existing routes ...
  
  resources :tags, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :categories, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  
  # Filter routes
  get '/posts/tagged/:tag', to: 'posts#index', as: :posts_tagged
  get '/posts/category/:category', to: 'posts#index', as: :posts_categorized
end
```

## Step 9: Update Views

### Update Post Form
```erb
<!-- app/views/posts/_form.html.erb -->
<!-- Add after status field -->
<div class="my-5">
  <%= form.label :tag_names, "Tags" %>
  <%= form.text_field :tag_names, value: post.tag_names.join(', '), 
                      placeholder: "Enter tags separated by commas",
                      class: ["block shadow-sm rounded-md border px-3 py-2 mt-2 w-full",
                             {"border-gray-400 focus:outline-blue-600": post.errors[:tag_names].none?,
                              "border-red-400 focus:outline-red-600": post.errors[:tag_names].any?}] %>
</div>

<div class="my-5">
  <%= form.label :category_names, "Categories" %>
  <%= form.select :category_names, 
                  options_from_collection_for_select(Category.by_name, :name, :name, post.category_names),
                  { include_blank: "Select categories..." }, 
                  { multiple: true, 
                    class: ["block shadow-sm rounded-md border px-3 py-2 mt-2 w-full",
                           {"border-gray-400 focus:outline-blue-600": post.errors[:category_names].none?,
                            "border-red-400 focus:outline-red-600": post.errors[:category_names].any?}] } %>
</div>
```

### Update Post Display
```erb
<!-- app/views/posts/show.html.erb -->
<!-- Add after post content -->
<% if @post.tags.any? %>
  <div class="mt-6">
    <h3 class="text-lg font-semibold mb-2">Tags:</h3>
    <div class="flex flex-wrap gap-2">
      <% @post.tags.each do |tag| %>
        <%= link_to tag.name, posts_tagged_path(tag), 
                    class: "px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm hover:bg-blue-200" %>
      <% end %>
    </div>
  </div>
<% end %>

<% if @post.categories.any? %>
  <div class="mt-4">
    <h3 class="text-lg font-semibold mb-2">Categories:</h3>
    <div class="flex flex-wrap gap-2">
      <% @post.categories.each do |category| %>
        <%= link_to category.name, posts_categorized_path(category), 
                    class: "px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm hover:bg-green-200" %>
      <% end %>
    </div>
  </div>
<% end %>
```

## Step 10: Create Work Model (Portfolio)

### Generate Work Model
```bash
bin/rails generate model Work title:string description:text status:integer tech_stack:text project_url:string github_url:string user:references
```

### Update Work Model
```ruby
# app/models/work.rb
class Work < ApplicationRecord
  include Taggable
  include Categorizable
  
  enum :status, { draft: 0, published: 1 }
  
  belongs_to :user
  has_rich_text :description
  has_many_attached :images
  
  validates :title, presence: true
  validates :description, presence: true
end
```

## Step 11: Create WorksController

```ruby
# app/controllers/works_controller.rb
class WorksController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_work, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[index show]
  
  def index
    @works = Work.published.order(created_at: :desc)
    @works = @works.tagged_with(params[:tag]) if params[:tag].present?
    @works = @works.in_category(params[:category]) if params[:category].present?
  end
  
  def show
  end
  
  def new
    @work = current_user.works.build
  end
  
  def create
    @work = current_user.works.build(work_params)
    if @work.save
      redirect_to @work, notice: 'Work was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @work.update(work_params)
      redirect_to @work, notice: 'Work was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    @work.destroy!
    redirect_to works_path, notice: 'Work was successfully deleted.'
  end
  
  private
  
  def set_work
    @work = Work.find(params[:id])
  end
  
  def work_params
    params.require(:work).permit(:title, :description, :status, :tech_stack, 
                                 :project_url, :github_url, images: [], 
                                 tag_names: [], category_names: [])
  end
end
```

## Implementation Order

1. **Database Setup** (Steps 1-3, 6): Create models and migrations
2. **Concerns** (Step 4): Create reusable functionality
3. **Model Updates** (Step 5): Include concerns in Post model
4. **Testing**: Verify basic functionality works
5. **Controllers** (Step 7): Update existing and create new controllers
6. **Routes** (Step 8): Add routing support
7. **Views** (Step 9): Update forms and display
8. **Portfolio Extension** (Steps 10-11): Add Work model and controller

## Testing Commands

After each major step, test with:
```bash
bin/rails console
# Test tag creation
tag = Tag.create(name: "Ruby")
post = Post.first
post.tags << tag
post.tag_names = ["Rails", "Web Development"]
post.save
```

## Additional Features (Future)

- Tag clouds with usage counts
- Auto-completion for tag input
- Tag merging functionality
- Category hierarchies (parent/child)
- Popular tags/categories widgets
- SEO-friendly tag/category pages