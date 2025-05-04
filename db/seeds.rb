# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.find_or_create_by!(email_address: "herwindo.artono@gmail.com") do |u|
  u.password = "qweasd"
  u.password_confirmation = "qweasd"
end

Post.create!(
  [
    {
      title: "First Blog Post",
      content: "This is the content of the first post. <b>Welcome!</b>",
      status: :published,
      user: user
    },
    {
      title: "Second Post (Draft)",
      content: "This is a draft post.",
      status: :draft,
      user: user
    }
  ]
)