#!/usr/bin/env ruby

# 創建超級管理員用戶
puts "Creating super admin user..."

user = User.find_by(email: 'jesse.chang@roycetechnology.com')

if user
  puts "User already exists with ID: #{user.id}"
  user.update!(super_admin: true, confirmed_at: Time.current)
  puts "Updated user to super admin"
else
  user = User.create!(
    email: 'jesse.chang@roycetechnology.com',
    password: 'Jesse123!',
    name: 'Jesse Chang',
    confirmed_at: Time.current,
    super_admin: true
  )
  puts "Super admin user created successfully with ID: #{user.id}"
end

puts "Email: #{user.email}"
puts "Super Admin: #{user.super_admin}"
puts "Confirmed: #{user.confirmed_at.present?}"
