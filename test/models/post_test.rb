require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should default status to draft" do
    post = Post.new(user: users(:one), title: "Test Post", content: "Test content") # Assuming you have fixtures for users
    assert_predicate post, :draft?
    assert_equal "draft", post.status
  end

  test "can set status to published" do
    post = Post.new(user: users(:one), title: "Test Post", content: "Test content", status: :published) # Assuming you have fixtures for users
    assert_predicate post, :published?
    assert_equal "published", post.status
  end

  test "status is draft by default when created via scope" do
    # This assumes current_user is set, which might be tricky in model tests directly.
    # If current_user is available (e.g. through a test helper or if you set it up), this test would be more direct.
    # For now, we'll test the default value directly on a new object.
    post = Post.new
    assert_equal "draft", post.status
  end

  test "creating a post with string status 'published' works" do
    # This test is more relevant for controller tests but adding here to ensure model handles it via enum.
    post = Post.new(user: users(:one), title: "Test Post", content: "Test content", status: "published")
    assert_predicate post, :published?
  end

  test "creating a post with string status 'draft' works" do
    post = Post.new(user: users(:one), title: "Test Post", content: "Test content", status: "draft")
    assert_predicate post, :draft?
  end
end
