class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.all
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    versions = Version.where(song_id: @song.id)
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
          key: version_key,
          songparts: version_text
        }
        default_version = Version.create!(version_params)

        format.html { redirect_to default_version, notice: 'Song was successfully created.' }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url, notice: 'Song was successfully destroyed.' }
      format.json { head :no_content }
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
end
