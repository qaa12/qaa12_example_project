module Api
  require 'google/apis/analyticsreporting_v4'
  require 'signet/oauth_2/client'
  require 'google/api_client/auth/key_utils'

  class GaApi
    SERVICE_ACCOUNT_EMAIL_ADDRESS = '########'
    PATH_TO_KEY_FILE              = Rails.root+'lib/ga.p12' # the path to the downloaded .p12 key file
    BASIC_METRICS = %w(ga:pageviewsPerSession
                      ga:avgSessionDuration 
                      ga:sessions
                      ga:newUsers
                      ga:pageviews
                      ga:bounceRate
                      ga:users
                      ga:bounces
                    )

    extend Dry::Initializer
    param :ga_id, proc(&:to_s)
    option :date_to, proc(&:to_date)
    option :date_from, proc(&:to_date)

    def client 
      return @client if @client
      @client = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
      @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience             => 'https://accounts.google.com/o/oauth2/token',
        :scope                => 'https://www.googleapis.com/auth/analytics.readonly',
        :issuer               => SERVICE_ACCOUNT_EMAIL_ADDRESS,
        :signing_key          => Google::APIClient::KeyUtils.load_from_pkcs12(PATH_TO_KEY_FILE, '###')
      ).tap { |auth| auth.fetch_access_token! }
      @client
    end

    def ga_metrics(mobile: false, metrics: BASIC_METRICS)
      return nil if @ga_id.blank?
      dims = []
      dims << 'ga:segment' if mobile
      segment = mobile ? 'gaid::-14' : false
      request = ga_init_request(metrics, dimensions_arr: dims, ga_segment: segment)

      date_range = ga_set_range(@date_from, @date_to)
      request.date_ranges = [date_range]

      report = ga_get_report(request)
      res = report[:reports][0][:data][:totals][0][:values]
      result = {}
      metrics.each_with_index do |metric, index|
        result[metric] = res[index].to_f
      end
      result
    end

    def ga_sources
      return nil if @ga_id.blank?
    
      metrics = ['ga:sessions']
      source_dimensions = ['ga:source', 'ga:segment']
      source_request = ga_init_request(metrics, dimensions_arr: source_dimensions, ga_segment: 'gaid::-8')

      order = ga_set_order('ga:sessions', 'DESCENDING')
      source_request.order_bys = [order]

      date_range = ga_set_range(@date_from, @date_to)
      source_request.date_ranges = [date_range]

      ga_get_report(source_request)
    end

    def ga_sources_mediums
      return nil if @ga_id.blank?
    
      metrics = ['ga:users']
      source_dimensions = ['ga:sourceMedium']
      source_request = ga_init_request(metrics, dimensions_arr: source_dimensions, ga_segment: false)

      order = ga_set_order('ga:users', 'DESCENDING')
      source_request.order_bys = [order]

      date_range = ga_set_range(@date_from, @date_to)
      source_request.date_ranges = [date_range]

      ga_get_report(source_request)
    end


    private 

    def ga_init_request(metrics_arr, dimensions_arr: nil, ga_segment: false)
      request = Google::Apis::AnalyticsreportingV4::ReportRequest.new
      request.view_id = @ga_id.to_s
      request.metrics = []
      metrics = metrics_arr
      metrics.each do |m|
        metric = Google::Apis::AnalyticsreportingV4::Metric.new
        metric.expression = m
        request.metrics << metric
      end

      unless dimensions_arr.nil?
        request.dimensions = []
        dimensions = dimensions_arr
        dimensions.each do |d|
          dimension = Google::Apis::AnalyticsreportingV4::Dimension.new
          dimension.name = d
          request.dimensions << dimension
        end
      end

      if ga_segment
        segment = Google::Apis::AnalyticsreportingV4::Segment.new
        segment.segment_id = ga_segment
        request.segments = [segment]
      end

      request
    end

    def ga_set_range(start_date, end_date)
      range = Google::Apis::AnalyticsreportingV4::DateRange.new
      range.start_date = start_date.to_s
      range.end_date = end_date.to_s
      range
    end

    def ga_set_cohort(name, type, date_range)
      cohort = Google::Apis::AnalyticsreportingV4::Cohort.new
      cohort.name = name
      cohort.type = type
      cohort.date_range = date_range
      cohort
    end

    def ga_set_order(field_name, sort_order)
      order = Google::Apis::AnalyticsreportingV4::OrderBy.new
      order.field_name = field_name
      order.sort_order = sort_order
      order
    end

    def ga_get_report(request)
      get_request = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new
      get_request.report_requests = [request]
      report = client.batch_get_reports(get_request).to_json
      report = JSON.parse(report, symbolize_names: true)
      report
    end
  end
end
