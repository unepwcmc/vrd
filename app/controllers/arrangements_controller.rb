class ArrangementsController < ApplicationController
  caches_page :show

  def index
    @arrangements = Arrangement.search(params)

    render json: @arrangements
  end

  def show
    @arrangement = Arrangement.find_by_id_feed(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @arrangement }
    end
  end
end
