class Api::V1::CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :ensure_connection

  def parse()
    input = command_params[:input]

    if input == "classes"
      render json: [BaseConnection.classes.join(", ")]
    elsif BaseConnection.classes.any? { |c| c === input }
      klass = Object.const_get(input)
      query_methods = %w(select where limit joins find_by all)
      query_methods.concat(klass.query_methods)

      render json: query_methods
    elsif BaseConnection.classes.any? { |c| c === input.split(".")[0] }
      klass = Object.const_get(input.split(".")[0])
      query_methods = %w(select where limit joins find_by all)
      query_methods.concat(klass.query_methods)
      _methods = input.split(".")[1..-1]
      
      meth = /^(?<m>\w*)\(?/
      arg = /\((?<arg>.*)\)$/
      raise "fatal" unless _methods.all? { |m| query_methods.include?(m.match(meth)[:m]) }

      _methods.map! { |m| [m.match(meth)[:m], m.match(arg)&.[](:arg)] }

      hash = /(?<k>[\w]*): (?<v>'?[\w]*'?),?/
      _methods.each do |(m,a)|

        if a 
          a = /^(("|').*("|'))$/.match?(a) ?
            a[1..-2] :
            {a.match(hash)[:k] => a.match(hash)[:v]}
        end


        klass = a ?
          klass.send(m, a):
          klass.send(m)
      end

      render json: klass
    else
      render json: SastMan.new(input)
    end
  end

  private
  def command_params
    params.require("command").permit("input")
  end
end
