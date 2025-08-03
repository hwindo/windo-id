class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!, except: [ :index, :show ]

  # index
  def index
    @categories = Category.by_name.includes(:categorizables)
  end

  # show
  def show
    @posts = Post.in_category(@category.name).published.recent
  end

  # new
  def new
    @category = Category.new
  end

  # create
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "Category created successfully."
    else
      render :new
    end
  end

  def edit
  end

  # update
  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Category updated successfully"
    else
      render :edit
    end
  end

  # delete
  def destroy
    @category.destroy!
    redirect_to categories_path, notice: "Category deleted successfully"
  end

  private

  def set_category
    @category = Category.find_by!(slug: params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
