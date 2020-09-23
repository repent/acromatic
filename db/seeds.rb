# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

case Rails.env
when "development"

user = User.create! email: 'dan.hetherington@gmail.com', password: 'password', password_confirmation: 'password'

dictionaries = Dictionary.create(
  [{name: 'Words and that'}])

definitions = Definition.create([
  {initialism: 'AA', dictionary: dictionaries.first, meaning: 'Automobile Association'},
  {initialism: 'AA', dictionary: dictionaries.first, meaning: 'Alcoholics Anonymous'},
  {initialism: 'BB', dictionary: dictionaries.first, meaning: "Beautiful booty"},
  {initialism: 'BB', dictionary: dictionaries.first, meaning: "Beautiful booty"},
  {initialism: 'BB', dictionary: dictionaries.first, meaning: "Bountiful beauty"},
  {initialism: 'CC', dictionary: dictionaries.first, meaning: "Crap cardiologist"},
  {initialism: 'DD', dictionary: dictionaries.first, meaning: "Directionless dentist"}
])

end