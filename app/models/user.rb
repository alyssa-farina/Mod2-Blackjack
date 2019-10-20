class User < ApplicationRecord
    has_many :games
    has_secure_password
  
    validates :name , presence: true
    validates :name, uniqueness: true
  
end
