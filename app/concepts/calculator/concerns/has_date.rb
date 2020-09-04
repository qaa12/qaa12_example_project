module Calculator
  module Concerns
    module HasDate
      extend ActiveSupport::Concern
      included do
        option :date_to, proc(&:to_date)
        option :date_from, proc(&:to_date)
      end
    end
  end
end
