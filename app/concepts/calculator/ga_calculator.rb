module Calculator
  class GaCalculator
    extend Dry::Initializer
    include Concerns::HasBrand
    include Concerns::HasDate

    def api
      @api ||= Api::GaApi.new(brand.ga_id, date_from: @date_from, date_to: @date_to)
    end
    
    def daily_sessions
      Rails.cache.fetch("#{cache_key}:daily_sessions", expires_in: 1.hours) do
        report_sessions = api.ga_request_graph(['ga:sessions'])
        report_bounces = api.ga_request_graph(['ga:bounces'])
        [ report_to_graph(report_sessions), report_to_graph(report_bounces) ]
      end
    end
    
    def daily_users
      Rails.cache.fetch("#{cache_key}:daily_users", expires_in: 1.hours) do
        report_sessions = api.ga_request_graph(['ga:users'])
        report_bounces = api.ga_request_graph(['ga:bounces'])
        [ report_to_graph(report_sessions), report_to_graph(report_bounces) ]
      end
    end
    
    def metrics
      Rails.cache.fetch("#{cache_key}:metrics", expires_in: 1.hours) do
        report = api.ga_metrics
      end
    end

    private

    def cache_key
      @cache_key ||= "#{brand.ga_id}/#{@date_from}/#{@date_to}"
    end

    def report_to_graph(report)
      graph = []
      return [{date: Date.today, count: 0}] if report[:reports][0][:data][:rows].nil?
      report[:reports][0][:data][:rows].each do |point| 
        t = []
        date = point[:dimensions][0]
        t << "#{date[0..3]}-#{date[4..5]}-#{date[6..7]}"
        t << point[:metrics][0][:values][0].to_i
        graph << t
      end
      { data: graph }
    end

  end
end
