
class Lean::User < Lean::Model
  @table = :user

  attr_reader :id
  attr_accessor :username
  attr_accessor :name
  attr_accessor :email
  attr_accessor :password
  attr_accessor :salt
  attr_accessor :active
end
