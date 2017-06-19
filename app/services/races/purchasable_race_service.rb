module Services
  module Races
    class PurchasableRaceService
      include Serviceable

      def initialize(search_params)
        @seq_id     = search_params[:seq_id].to_i
        @page_size  = search_params[:page_size]
        @keyword    = search_params[:keyword]
      end

      def call
        races = if @keyword.blank?
                  purchasable_races
                else
                  with_keyword_races
                end
        races = races.where('races.seq_id > ?', @seq_id).limit(@page_size).seq_asc
        ApiResult.success_with_data(races: races)
      end

      def purchasable_races
        Race.left_joins(:sub_races)
            .where(parent_id: 0)
            .where('races.ticket_sellable = ? or sub_races_races.ticket_sellable = ?', 1, 1)
            .distinct
        # Race.main.ticket_sellable
      end

      def with_keyword_races
        purchasable_races.where('races.name like ? or races.location like ?', "%#{@keyword}%", "%#{@keyword}%")
      end
    end
  end
end
