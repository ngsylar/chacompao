class FavoritesController < ApplicationController
  before_action :set_favorite, only: [:destroy]
  before_action :authenticate_user!

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
    end

    # Only allow a list of trusted parameters through.
    def favorite_params
      params.require(:favorite).permit(:user_id, :version_id)
    end
end
