module Calculator
  class BrandQuadCalculator
    extend Dry::Initializer
    include Concerns::HasBrand
    include Concerns::HasDate

    def reviews(skus:)
      # (spider: 'ozon.ru', brand: 'Mentos')
      Rails.cache.fetch("#{cache_key}/#{skus}:reviews", expires_in: 1.day) do
        response = Api::BrandquadApi.new.get_comments(spider: 'ozon.ru', brand: brand.name , skus: skus)
        data = JSON.parse response.body
        data['reviews'].map{|x| x['comment']}
      end
    end

    def cache_key
      @cache_key ||= "#{brand.id}/#{@date_from}/#{@date_to}"
    end

  end
end

