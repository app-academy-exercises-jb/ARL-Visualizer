# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

10.times do |userIdx|
  user = User.create(fname: Faker::Name.first_name, lname: Faker::Name.last_name)
  (rand(5) + 1).times do |postIdx|
    post = Post.create(
      author_id: user.id,
      title: Faker::Lorem.words(number: rand(5) + 2).join(" "),
      body: Faker::Lorem.words(number: rand(15) + 5).join(" ")
    )
    
    rand(3).times do 
      Comment.create(
        author_id: rand(userIdx),
        post_id: rand(postIdx),
        body: Faker::Lorem.words(number: rand(7) + 3).join(" ")
      )
    end
  end
end