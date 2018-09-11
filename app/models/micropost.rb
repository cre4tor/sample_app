class Micropost < ApplicationRecord
  #マイクロポストがユーザーに所属する (belongs_to) 関連付け
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
