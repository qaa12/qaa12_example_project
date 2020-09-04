module Api
  class ScreensController < ApiController
    def index
      render json: ScreenBlueprint.render(screens)
    end

    def show
      render json: ScreenBlueprint.render(screen)
    end

    def rotations
      RotationsGenOperation.new.call(screen) do |m|
        m.success do |result|
          render json: result
        end
        handle_failed_monad(m)
      end
    end

    private

    def screen
      @screen ||= Screen.find(params[:id])
    end

    def screens
      @screens ||= Screen.all
    end
  end
end
