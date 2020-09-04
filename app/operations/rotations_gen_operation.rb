class RotationsGenOperation
  include Dry::Transaction
  # include OperationsErrorHandler

  step :get_pages
  step :get_brands
  step :create_rotations
  step :render

  private

  def get_pages(screen)
    @pages = screen.pages
    Success(@pages)
  end

  def get_brands(pages)
    @brands = [Brand.find(Time.now.min / 4 % Brand.count + 1)]
    Success(@brands)
  end

  def create_rotations
    rotations = []
    @brands.each do |brand|
      @pages.each do |page|
        template_datas = template_data_gen(page, brand)
        template_datas.each do |t_d|
          rotations << Rotation.new(
            brand_id: brand.id,
            template: page.template,
            template_data: t_d[:data],
            rotation_time: t_d[:time]
          )
        end
      end
    end
    Success(rotations)
  end

  def render(rotations)
    Success( RotationBlueprint.render(rotations) )
  end

  private 

  def template_data_gen(page, brand)
    case page.template
    when 'Static'
      brand.statics.map do |static|
        { data: static.image_url, time: page.rotation_time }
      end
    when 'Youtube'
      brand.youtubes.map do |youtube|
        { data: youtube.url_id, time: youtube.duration*1000 }
      end
    when 'MarketPlace'
      brand.reviews.map do |review|
        { data: ReviewBlueprint.render_as_hash(review), time: page.rotation_time }
      end
    else
      [{ data: brand.id, time: page.rotation_time }]
    end
  end
end
