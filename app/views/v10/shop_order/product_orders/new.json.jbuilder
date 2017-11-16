# meta info
json.partial! 'common/meta'
# code & msg
json.partial! 'common/api_result', api_result: ApiResult.success_result
# data
json.data do
  json.items do
    json.array! @pre_purchase_items.order_items do |item|
      json.number  item.number
      json.variant do
        json.partial! 'v10/shop/products/variant', variant: item.variant
      end
    end
  end

  json.shipping_price      @pre_purchase_items.shipping_price
  json.total_product_price @pre_purchase_items.total_product_price
  json.total_price         @pre_purchase_items.total_price
  json.freight_free        @pre_purchase_items.freight_free?
end