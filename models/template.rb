require 'sequel'
class Template < Sequel::Model(:templates)
  one_to_many :users
end