json.extract! post, :id, :title, :content, :status, :user_id, :created_at, :updated_at
json.url post_url(post, format: :json)
json.content post.content.to_s
