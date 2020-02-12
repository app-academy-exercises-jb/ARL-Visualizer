class Api::V1::TestsController < ApplicationController
  def teset
    render json: {a: 0, b: 1, c: 2}
  end
end
