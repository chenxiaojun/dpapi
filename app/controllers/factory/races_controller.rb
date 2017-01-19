module Factory
  class RacesController < ApplicationController
    include DataIntegration::Races
    include Constants::Error::Common

    def create
      method = params[:method] || ''
      unless method.to_sym.in? DataIntegration::Races.instance_methods
        return render_api_error(MISSING_PARAMETER)
      end
      send(method)
      render_api_success
    end

    def init_followed_or_ordered_races
      if params[:uuid]
        user = User.by_uuid(params[:uuid])
      else
        user = FactoryGirl.create(:user, user_params.as_json)
      end
      super(user)
    end
  end
end
