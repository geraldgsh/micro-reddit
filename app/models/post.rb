# frozen_string_literal: true

class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 45 }
  validates :body, presence: true, length: { maximum: 200 }
  belongs_to :user
  has_many :comments
end
