module V10
  module ShopOrders
    class CancelController < ApplicationController
      include UserAccessible
      include Constants::Error::Order
      before_action :login_required
      before_action :set_order

      def create
        return render_api_error(CANNOT_CANCEL) unless @order.status == 'unpaid'
        @order.cancel_order('用户取消订单')
        # 返回库存
        @order.product_order_items.each do |item|
          item.variant[:stock] += item.number
          item.variant.save
        end
        render_api_success
      end

      private

      def set_order
        @order = @current_user.product_orders.find_by!(order_number: params[:product_order_id])
      end
    end
  end
end
