require 'sequel'
class Operation < Sequel::Model(:operations)
  many_to_one :user

  def confirmed?
    done == true
  end
end