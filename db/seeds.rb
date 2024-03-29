# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Versions
Version.destroy_all

# Songs
Song.destroy_all

# Users
User.destroy_all
User.create(full_name: "Administrador", email: "admin@ccp.com", password: "admin123", role: "administrator")
User.create(full_name: "Instrumentista", email: "musician@ccp.com", password: "admin123", role: "musician")
# User.create(full_name: "Usuario", email: "comuser@ccp.com", password: "admin123", role: "commonuser")
