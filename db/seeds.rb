# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

categories = %w[jugando pendiente completado en_pausa descartado].map do |slug|
  name = slug.tr('_', ' ')
  description = case slug
  when 'jugando' then 'Juegos que estás jugando actualmente'
  when 'pendiente' then 'Juegos que tienes pendientes por jugar'
  when 'completado' then 'Juegos que ya has terminado'
  when 'en_pausa' then 'Juegos que has dejado en pausa'
  when 'descartado' then 'Juegos que has descartado o abandonado'
  else ''
  end

  Category.find_or_create_by(name: name) do |cat|
    cat.description = description
  end
end

puts "✅ Categorías creadas o encontradas: #{categories.map(&:name).join(', ')}"

user = User.find_or_create_by(email: 'user@example.com') do |u|
  u.name = 'Usuario Normal'
  u.password = 'password123'
  u.password_confirmation = 'password123'
end
puts "✅ Usuario normal: #{user.email} (contraseña: 'password123')"

admin = AdminUser.find_or_create_by(email: 'admin@example.com') do |a|
  a.name = 'Administrador'
  a.password = 'password123'
  a.password_confirmation = 'password123'
end
puts "✅ Administrador: #{admin.email} (contraseña: 'password123')"
