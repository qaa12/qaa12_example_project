module Api
  class DataController < ApiController
    def ys_daily_mentions
      CalculateOperation.new
        .with_step_args(
          init: [ calculator: Calculator::YsCalculator ],
          render: [ blueprint: DailyMentionsBlueprint ]
        )
        .call(params) do |m|
        m.success do |result|
          render json: result
        end
        handle_failed_monad(m)
      end
    end

    def ys_mentions
      CalculateOperation.new
        .with_step_args(
          init: [ calculator: Calculator::YsCalculator ],
          render: [ blueprint: MentionsBlueprint ]
        )
        .call(params) do |m|
        m.success do |result|
          render json: result
        end
        handle_failed_monad(m)
      end
    end

    def ga_daily_sessions
      CalculateOperation.new
        .with_step_args(
          init: [ calculator: Calculator::GaCalculator ],
          render: [ blueprint: DailySessionsBlueprint ]
        )
        .call(params) do |m|
        m.success do |result|
          render json: result
        end
        handle_failed_monad(m)
      end
    end

    def sb_daily_fans
      CalculateOperation.new
        .with_step_args(
          init: [ calculator: Calculator::SbCalculator ],
          render: [ blueprint: DailyFansBlueprint ]
        )
        .call(params) do |m|
        m.success do |result|
          render json: result
        end
        handle_failed_monad(m)
      end
    end

    def tv_spots
      CalculateOperation.new
        .with_step_args(
          init: [ calculator: Calculator::TvSpotCalculator ],
          render: [ blueprint: TvSpotBlueprint ]
        )
        .call(params) do |m|
        m.success do |result|
          render json: result
        end
        handle_failed_monad(m)
      end
    end
  end
end
