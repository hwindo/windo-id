class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: [ :show, :edit, :update ]

  def index
    @tags = Tag.by_name.includes(:taggables)
  end

  def show
    @posts = Post.tagged_with(@tag.name).recent
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
        redirect_to tags_path, notice: "Tag created successfully."
    else
      render :new
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to tags_path, notice: "Tag updated successfully."
    else
    render :edit
    end
  end

  def destroy
    @tag.destroy!
    redirect_to tags_path, notice: "Tag deleted successfully."
  end

  private

  def set_tag
    @tag = Tag.find_by!(slug: params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
