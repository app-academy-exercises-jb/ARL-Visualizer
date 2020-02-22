class Api::V1::CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :ensure_connection

  def parse()
    input = command_params[:input]

    # debugger 
    if input == "classes"
      render json: [BaseConnection.classes.join(", ")]
    elsif BaseConnection.classes.any? { |c| c === input }
      klass = Object.const_get(input)
      query_methods = %w(select where limit joins find_by all)
      query_methods.concat(klass.query_methods)

      render json: query_methods
    else
      render json: SastMan.new(input)
    end
  end

  private
  def command_params
    params.require("command").permit("input")
  end
end
