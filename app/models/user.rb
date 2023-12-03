class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books,dependent: :destroy
  has_one_attached :profile_image
  has_many :favorites,dependent: :destroy
  has_many :book_comments,dependent: :destroy
  # フォローする、されるの関係
  has_many :to_follow,class_name:"Relationship", foreign_key:"follower_id", dependent: :destroy
  has_many :be_followed,class_name:"Relationship", foreign_key:"followed_id", dependent: :destroy
  #一覧画面で使う
  has_many :followings, through: :to_follow, source: :followed
  has_many :followers, through: :be_followed, source: :follower

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction,length: {maximum:50}


  #フォロー機能
  def follow(user_id)
    to_follow.create(followed_id: user_id)
  end

  def unfollow(user_id)
    to_follow.find_by(followed_id: user_id).destroy
  end
  #フォローしているか判定
  def following?(user)
    followings.include?(user)
  end


  def get_profile_image(width,height)
    unless profile_image.attached?
      file_path = Rails.root.join('app/assets/images/no_image.jpg')
      profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
    end
    profile_image.variant(resize_to_limit: [width,height]).processed
  end
end
