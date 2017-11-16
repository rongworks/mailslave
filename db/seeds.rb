# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
u1 = User.create!(name:'admin',email:'admin@example.com',password:'password',password_confirmation:'password')
u2 = User.create! :name => 'John Doe', :email => 'john@gmail.com', :password => 'topsecret', :password_confirmation => 'topsecret'
acc1 = MailAccount.create!("name"=>"Test1", "email"=>"mailarchiv-test@kaiser-tappe.de", "user_id"=>u2.id, "login"=>"mailarchiv-test@kaiser-tappe.de", "password"=>"lFKytjSWYKGaXRMNSOIu", "port"=>"993", "ssl"=>"1", "host"=>"sslin.de")

