class DailySessionsBlueprint < Blueprinter::Base
  field :brand_render, name: :brand
  fields :date_from, :date_to
  fields :sources_mediums, :daily_users, :metrics
end
