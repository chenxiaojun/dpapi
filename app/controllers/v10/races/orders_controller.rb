module V10
  module Races
    class OrdersController < ApplicationController
      include Constants::Error::Common
      include UserAccessible

      before_action :set_race, :login_required

      def new_order
        @user = @current_user
        render 'new_order'
      end

      def create
        result = Services::Races::OrderGenerator.call(@race, @current_user, params)
        return render_api_error(result.code, result.msg) if result.failure?

        render_api_success
      end

      private

      def set_race
        @race = Race.find(params[:race_id])
      end
    end
  end
end