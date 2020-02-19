class Api::V1::CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def parse()
    input = command_params[:input]

    # debugger
    render json: SastMan.new(input)
  end

  private
  def command_params
    params.require("command").permit("input")
  end
end
