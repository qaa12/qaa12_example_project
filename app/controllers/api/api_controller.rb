module Api
  class ApiController < ApplicationController
    def params
      request.params
    end
    
    private

    def handle_failed_monad(monad)
      monad.failure :validate do |validate|
        render json: { status: 400, error: validate.errors.to_h }, status: 400
      end
      monad.failure :check_permission do |permission|
        render json: { status: 403, error: permission }, status: 403
      end
      monad.failure do |error|
        render json: { status: 500, error: error }, status: 500
      end
    end 
  end
end
