class CalculateOperation
  include Dry::Transaction
  # include OperationsErrorHandler

  step :validate
  step :init
  step :render

  private

  def validate(params, validator: BaseValidator)
    validator.new.call(params).to_monad
  end

  def init(params, calculator:)
    calc = calculator.new(
      brand_id: params[:brand_id],
      date_from: params[:date_from].to_date,
      date_to: params[:date_to].to_date
    )
    Success(calc)
  end

  def render(calc, blueprint:)
    result = blueprint.render(calc)
    Success(result)
  end
end
