class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favorite, only: [:destroy]

  # GET /favorites
  # GET /favorites.json
  def index
    @favorites = Favorite.where(user_id: current_user.id).sorted_by_song_title
  end

  # DELETE /favorites/1
  # DELETE /favorites/1.json
  def destroy
    @favorite.destroy
    respond_to do |format|
      format.html { redirect_to favorites_url, notice: 'Cifra removida da lista de favoritas.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite
      @favorite = Favorite.find(params[:id])
      unless user_signed_in? && (@favorite.user_id == current_user.id)
        redirect_to homepage_url, alert: 'Você não tem permissão para executar essa ação!'
      end
    end

    # Only allow a list of trusted parameters through.
    def favorite_params
      params.require(:favorite).permit(:user_id, :version_id)
    end
end
