module Calculator
  module Concerns
    module HasBrand
      extend ActiveSupport::Concern
      included do
        option :brand_id
      end

      def brand
        @brand ||= Brand.find(brand_id)
      end

      def brand_render
        BrandBlueprint.render_as_hash(brand)
      end
    end
  end
end
