class User < Sequel::Model(:users)
  many_to_one :template, class: :Template
  one_to_many :operations

  def bonus_balance
    self.bonus
  end
end