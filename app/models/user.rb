# frozen_string_literal: true

class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def stock_already_tracked?(ticker_symbol)
    stock = Stock.check_db(ticker_symbol)
    return false unless stock

    stocks.where(id: stock.id).exists?
  end

  def under_stock_limit?
    stocks.count < 10
  end

  def can_track_stock?(ticker_symbol)
    under_stock_limit? && !stock_already_tracked?(ticker_symbol)
  end

  def full_name
    return "#{first_name} #{last_name}" if first_name || last_name

    'Anonymous'
  end

  def self.search(param)
    param.strip!
    to_send_back = (first_name_matchers(param) + last_name_matchers(param) + email_matchers(param)).uniq
    return nill unless to_send_back

    to_send_back
  end

  def self.first_name_matchers(param)
    matchers('first_name', param)
  end

  def self.last_name_matchers(param)
    matchers('last_name', param)
  end

  def self.email_matchers(param)
    matchers('email', param)
  end

  def self.matchers(field_name, param)
    where("#{field_name} like ?", "%#{param}%")
  end
end
