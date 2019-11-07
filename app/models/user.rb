class User < ApplicationRecord
	validates :username, presence: true, uniqueness: true, length: { maximum: 25 }
	has_many :posts
end
