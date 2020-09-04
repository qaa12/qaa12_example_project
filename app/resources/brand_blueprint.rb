class BrandBlueprint < Blueprinter::Base    
  identifier :id
  fields :name, :color, :ga_id, :url
  field :logo_url
end
