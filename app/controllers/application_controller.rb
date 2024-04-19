# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActionController::ParameterMissing, with: :show_parameter_missing_error

  protected

    def authenticate_user(&block)
      return block&.call if current_user

      head :unauthorized
    end

    # TODO: go with devise way to dont reinvent the wheel
    def current_user
      @current_user ||= authenticate_with_http_token do |token|
        User.find_by(token: token)
      end
    end

    def render_json(status, json = {})
      render status: status, json: json
    end

    def show_parameter_missing_error(exception)
      render_json(400, error: exception.message)
    end

    def set_todo_lists
      user_todo_lists = current_user.todo_lists

      @todo_lists = todo_lists_only_non_default? ? user_todo_lists.non_default : user_todo_lists
    end
end
