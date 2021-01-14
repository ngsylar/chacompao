class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_song, only: [:show, :edit, :update, :destroy]
  before_action :ensure_admin, only: [:new, :edit, :update, :destroy]

  # GET /songs
  # GET /songs.json
  def index
    searchfilter = params[:search]

    if (searchfilter == nil) || (searchfilter.empty?)
      @songs = Song.order(
        "CASE
          WHEN LOWER(category) = 'contracapa' THEN '1'
          WHEN LOWER(category) = 'avulso' THEN '4'
          WHEN number IS NULL THEN '5'
          WHEN LOWER(category) != 'cias' THEN '2'
          WHEN LOWER(category) = 'cias' THEN '3'
        END",
        "number ASC", "LOWER(title)"
      )

    else
      @songs = Song.where(number: searchfilter)
      searchterm = I18n.transliterate(searchfilter.downcase)
      if @songs.empty?
        @songs = Song.where(
          "UNACCENT(LOWER(title)) like ?", "%#{searchterm}%"
        ).or(Song.where(id: defvers_ids(searchterm))).order(
          "CASE
            WHEN UNACCENT(LOWER(title)) like '#{searchterm}' THEN '1'
          END",
          "LOWER(title)"
        )
      end
    end
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    versions = Version.where(song_id: @song.id).order("LOWER(title)")
    fav = Favorite.find_by(user_id: current_user.id, song_id: @song.id)
    @fav_ver = nil
    @my_versions = []
    @other_vers = []
    
    versions.each do |version|
      if version.title == "default"
        @def_version = version
      elsif (fav != nil) && (version.id == fav.version_id)
        @fav_ver = version
      elsif version.user_id == current_user.id
        @my_versions << version
      else
        @other_vers << version
      end
    end
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  # POST /songs
  # POST /songs.json
  def create
    version_key = params[:song].delete("key")
    version_text = params[:song].delete("text")

    @song = Song.new(song_params)
    
    respond_to do |format|
      if @song.save
        version_params = {
          song_id: @song.id,
          user_id: current_user.id,
          title: "default",
          key: version_key.gsub(/\s/,''),
          songparts: version_text
        }
        default_version = Version.create!(version_params)

        format.html { redirect_to default_version, notice: 'Música enviada com sucesso.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to @song, notice: 'Informações atualizadas com sucesso.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url, notice: 'A música foi excluída.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def song_params
      params.require(:song).permit(:title, :author, :category, :number)
    end

    # 
    def defvers_ids (searchterm)
      defvers = Version.where(title: "default").where(
        "UNACCENT(LOWER(songparts)) like ?", "%#{searchterm}%")
      defvers.map(&:song_id).to_a
    end

    # 
    def ensure_admin
      unless user_signed_in? && (current_user.role == "administrator")
        redirect_to homepage_url, alert: 'Você não tem permissão para executar essa ação!'
      end
    end
end
