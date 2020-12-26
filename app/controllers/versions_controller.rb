class VersionsController < ApplicationController
  before_action :set_version, only: [:show, :edit, :update, :destroy]

  # GET /versions
  # GET /versions.json
  def index
    if current_user.role == "administrator"
      @versions = Version.all
    else
      @versions = Version.where(user_id: current_user.id)
    end
  end

  # GET /versions/1
  # GET /versions/1.json
  def show
    @song = Song.find(@version.song_id)
    @user = User.find(@version.user_id)
  end

  # GET /versions/new
  def new
    @version = Version.new

    @song = Song.find(params[:ref_song])
    default_version = Version.find_by(song_id: @song, title: "default")

    @default_key = default_version.key
    @default_text = default_version.handwrite
  end

  # GET /versions/1/edit
  def edit
    @song = Song.find(@version.song_id)
    @default_text = @version.handwrite
  end

  # POST /versions
  # POST /versions.json
  def create
    mandatory_params = {
      # song_id: @song.id,
      user_id: current_user.id
    }
    @version = Version.new(version_params.merge(mandatory_params))

    respond_to do |format|
      if @version.save
        format.html { redirect_to @version, notice: 'Version was successfully created.' }
        format.json { render :show, status: :created, location: @version }
      else
        format.html { render :new }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /versions/1
  # PATCH/PUT /versions/1.json
  def update
    mandatory_params = {
      songstruct: nil,
      partsstructs: nil
    }
    respond_to do |format|
      if @version.update(version_params.merge(mandatory_params))
        format.html { redirect_to @version, notice: 'Version was successfully updated.' }
        format.json { render :show, status: :ok, location: @version }
      else
        format.html { render :edit }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.json
  def destroy
    @version.destroy
    respond_to do |format|
      format.html { redirect_to request.referrer, notice: 'Version was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_version
      @version = Version.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def version_params
      params.require(:version).permit(:song_id, :user_id, :title, :key, :songstruct, :songparts, :partsstructs)
    end
end
