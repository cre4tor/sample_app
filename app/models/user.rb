class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # # 明示的にUserクラスを呼び出してdigest,new_tokenメソッドを定義
  # # 渡された文字列のハッシュ値を返す
  # def User.digest(string)
  #   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  #              BCrypt::Engine.cost
  #   BCrypt::Password.create(string, cost: cost)
  # end
  #
  # # ランダムなトークンを返す
  # def User.new_token
  #   SecureRandom.urlsafe_base64
  # end

  # # selfを使ってdigestとnew_tokenメソッドを定義
  # # 渡された文字列のハッシュ値を返す
  # def self.digest(string)
  #   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  #              BCrypt::Engine.cost
  #   BCrypt::Password.create(string, cost: cost)
  # end
  #
  # # ランダムなトークンを返す
  # def self.new_token
  #   SecureRandom.urlsafe_base64
  # end

  # class << selfを使ってdigestとnew_tokenメソッドを定義
  class << self
    # 渡された文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                 BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute,token)
    digest = self.send("#{attribute}_digest") #コードはモデル内にあるのでselfは省略可能
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  #アカウントを有効にする
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
    #update_columns(activated: true, activted_at: Time.zone.now) ←にするとtestがREDになる(原因分からない)
  end

  #有効用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

   #メールアドレスを全て小文字にする
   def downcase_email
    self.email.downcase!
   end

   #有効かトークンとダイジェストを作成及び代行する
   def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
   end
end
