class FibController < ApplicationController
  def show
    n = Integer(params.require(:n))
    render json: { "fib(#{n})" => fib(n) }
  rescue ArgumentError
    render json: "Invalid value", status: :unprocessable_entity
  end

private

  def fib(n)
    return n if n < 2
    fib(n - 1) + fib(n - 2)
  end
end
