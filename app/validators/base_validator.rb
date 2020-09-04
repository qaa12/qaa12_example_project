class BaseValidator < Dry::Validation::Contract
  params do
    required(:date_to).filled(:string)
    required(:date_from).filled(:string)
    required(:brand_id).filled(:integer)
  end
end
