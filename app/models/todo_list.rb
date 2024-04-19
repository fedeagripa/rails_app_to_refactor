# frozen_string_literal: true

class TodoList < ApplicationRecord
  has_many :todos, dependent: :destroy, inverse_of: :todo_list

  # TODO: Remove the required: true flag, is already default for belongs_to.
  # Also for adding non required should use ==> optional: true
  belongs_to :user, required: true, inverse_of: :todo_lists

  # TODO: This seems a bit redundant and we can probably use default || !default
  scope :default, -> { where(default: true) }
  scope :non_default, -> { where(default: false) }

  # TODO: Change this scope name to order_and_sort_by (or similar)
  scope :order_by, ->(params) {
    order = params[:order]&.strip&.downcase == 'asc' ? :asc : :desc

    sort_by = params[:sort_by]&.strip&.downcase

    column_name = column_names.excluding('id', 'user_id').include?(sort_by) ? sort_by : 'id'

    order(column_name => order)
  }

  validates :title, presence: true
  validates :default, inclusion: { in: [true, false] }
  validate :default_uniqueness

  def serialize_as_json
    as_json(except: [:user_id])
  end

  private

  def default_uniqueness
    errors.add(:default, 'already exists') if default? && user.todo_lists.default.exists?
  end
end
