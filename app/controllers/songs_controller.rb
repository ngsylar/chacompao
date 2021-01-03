class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  # GET /songs
  # GET /songs.json
  def index
    searchfilter = params[:search]

    if (searchfilter == nil) || (searchfilter.empty?)
      @songs = Song.order("number IS NULL, number ASC", "LOWER(title)")

    else
      @songs = Song.where(
        "unaccent(LOWER(title)) like ?", "%#{I18n.transliterate(searchfilter.downcase)}%"
      ).or(Song.where(id: defvers_ids(searchfilter))).order(
        "number IS NULL, number ASC", "LOWER(title)")
    end
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    versions = Version.where(song_id: @song.id).order("LOWER(title)")
    @my_versions = []
    @other_vers = []
    
    versions.each do |version|
      if version.title == "default"
        @def_version = version
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
        # format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new }
        # format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to @song, notice: 'Informações atualizadas com sucesso.' }
        # format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit }
        # format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url, notice: 'A música foi excluída.' }
      # format.json { head :no_content }
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
    def defvers_ids (searchfilter)
      defvers = Version.where(title: "default").where(
        "unaccent(LOWER(songparts)) like ?", "%#{I18n.transliterate(searchfilter.downcase)}%")
      defvers.map(&:song_id).to_a
    end
end
