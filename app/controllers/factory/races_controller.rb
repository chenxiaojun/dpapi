module Factory
  class RacesController < ApplicationController
    include DataIntegration::Races
    include Constants::Error::Common
    before_action :data_clear, if: :clear?

    def index
      method = params[:method] || ''
      unless method.to_sym.in? DataIntegration::Races.instance_methods
        return render_api_error(MISSING_PARAMETER)
      end
      send(method)
      render_api_success
    end

    def init_followed_or_ordered_races
      user = User.by_uuid(params[:uuid]) || FactoryGirl.create(:user)
      super(user)
    end
  end
end
