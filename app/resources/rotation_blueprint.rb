class RotationBlueprint < Blueprinter::Base
  fields :template, :template_data, :rotation_time
  field :brand_render, name: :brand
end
