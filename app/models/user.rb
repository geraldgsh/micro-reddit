# frozen_string_literal: true

class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }
  has_many :posts
  has_many :comments
end
