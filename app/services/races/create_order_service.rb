module Services
  module Races
    class CreateOrderService
      include Serviceable
      include Constants::Error::Common
      include Constants::Error::Race
      include Constants::Error::Account

      TICKET_TYPES = %w(e_ticket entity_ticket).freeze
      TICKET_STATUS_ERRORS = {
        unsold: TICKET_UNSOLD,
        end: TICKET_END,
        sold_out: TICKET_SOLD_OUT
      }.freeze
      attr_accessor :race, :user, :params
      def initialize(race, user, params)
        self.race   = race
        self.user   = user
        self.params = params
      end

      def call
        unless params[:ticket_type].in? TICKET_TYPES
          return ApiResult.error_result(UNSUPPORTED_TYPE)
        end

        unless race.ticket_status == 'selling'
          return ApiResult.error_result(TICKET_STATUS_ERRORS[race.ticket_status.to_sym])
        end

        return ApiResult.error_result(NO_CERTIFICATION) unless user.user_extra

        if Ticket.again_buy?(user.id, race.id)
          return ApiResult.error_result(AGAIN_BUY)
        end

        send("ordering_#{params[:ticket_type]}")
      end

      def ordering_e_ticket
        unless UserValidator.email_valid?(params[:email])
          return ApiResult.error_result(PARAM_FORMAT_ERROR)
        end

        if race.ticket_info.e_ticket_sold_out?
          return ApiResult.error_result(E_TICKET_SOLD_OUT)
        end

        @ticket = Ticket.create(ticket_params)
        order = PurchaseOrder.new(email_order_params)
        return ApiResult.success_with_data(order: order) if order.save

        ApiResult.error_result(SYSTEM_ERROR)
      end

      def ticket_params
        {
          user_id:         user.id,
          ticket_infos_id: race.ticket_info.id,
          race_id:         race.id,
          ticket_type:     params[:ticket_type]
        }
      end

      def init_order_params
        {
          user:           user,
          race:           race,
          ticket_id:      @ticket.id,
          price:          race.ticket_price,
          original_price: race.ticket_price,
          ticket_type:    params[:ticket_type],
          status:         'unpaid'
        }
      end

      def email_order_params
        init_order_params.merge(email: params[:email])
      end
    end
  end
end