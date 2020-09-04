class Rotation
  extend Dry::Initializer
  option :template
  option :template_data
  option :rotation_time
  include Calculator::Concerns::HasBrand
end
