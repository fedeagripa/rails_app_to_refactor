# frozen_string_literal: true

class User < ApplicationRecord
  has_many :todo_lists, dependent: :destroy, inverse_of: :user
  has_many :todos, through: :todo_lists # TODO: discuss our code guides to check if short lines should go first or last

  # TODO: would like to move this to a belongs_to on relation table (todo_list)
  has_one :default_todo_list, ->(user) { user.todo_lists.default }, class_name: 'TodoList'

  # EVALUATE: Depending on the project scope/needs/etc using devise for this and to win more useful features would be nice
  validates :name, presence: true
  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true
  validates :token, presence: true, length: { is: 36 }, uniqueness: true
  validates :password_digest, presence: true, length: { is: 64 }


  after_create :create_default_todo_list
  after_commit :send_welcome_email, on: :create

  private

  def create_default_todo_list
    todo_lists.create!(title: 'Default', default: true)
  end

  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_later
  end
end
