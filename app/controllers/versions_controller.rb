class VersionsController < ApplicationController
  before_action :set_version, only: [:show, :edit, :update, :destroy]
  @@key = 0
  @@on_click = "on"
  @@user_pref = 0

  # GET /versions
  # GET /versions.json
  def index
    @filter_term = params[:terms] || "updated_at"

    if current_user.role == "administrator"
      if @filter_term == "updated_at"
        @versions = Version.order(updated_at: :desc)
      else
        @versions = Version.sorted_by_song_title
      end
    else
      if @filter_term == "updated_at"
        @versions = Version.where(user_id: current_user.id).order(updated_at: :desc)
      else
        @versions = Version.where(user_id: current_user.id).sorted_by_song_title
      end
    end
  end

  # GET /versions/1
  # GET /versions/1.json
  def show
    @song = Song.find(@version.song_id)
    @user = User.find(@version.user_id)
    
    @key_name = ""
    key_change = params[:key_change].to_i
    @on_click = params[:on_click].to_s
    @clicked = @@on_click
    @user_pref = params[:prefs].to_i
    @@user_pref = @user_pref

    if key_change == 0
      @@key = 0
      @key = 0
      @on_click = @@on_click
    
    elsif key_change == 2
      @key = @@key
      @on_click = @@on_click

    else
      @@on_click = @on_click
      if @on_click != @clicked
        @@key += key_change
        @@key -= 12 if @@key > 11
        @@key += 12 if @@key < 0
      end
      @key = @@key
    end

    fav_ver = Favorite.find_by(user_id: current_user.id, song_id: @version.song_id)
    if params[:star].to_i == 1
      if fav_ver == nil
        Favorite.create!(user_id: current_user.id, song_id: @version.song_id, version_id: @version.id)
      elsif fav_ver.version_id != @version.id
        fav_ver.destroy
        Favorite.create!(user_id: current_user.id, song_id: @version.song_id, version_id: @version.id)
      end
    elsif params[:star].to_i == -1
      fav_ver.destroy if fav_ver != nil
    end
    @disp_fav = Favorite.find_by(user_id: current_user.id, version_id: @version.id)
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
    song_id = version_params["song_id"]

    mandatory_params = {
      # song_id: @song.id,
      user_id: current_user.id,
      key: version_params["key"].gsub(/\s/,'')
    }
    @version = Version.new(version_params.merge(mandatory_params))

    respond_to do |format|
      if (@version.title == "default") && (current_user.role != "administrator")
        format.html { redirect_to Song.find(song_id), alert: "O nome da cifra não pode ser \"default\" (nome reservado)" }
      elsif @version.save
        format.html { redirect_to @version, notice: 'Cifra enviada com sucesso.' }
        # format.json { render :show, status: :created, location: @version }
      else
        format.html { redirect_to Song.find(song_id), alert: 'A cifra não pôde ser enviada!' }
        # format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /versions/1
  # PATCH/PUT /versions/1.json
  def update
    mandatory_params = {
      key: version_params["key"].gsub(/\s/,''),
      songstruct: nil,
      partsstructs: nil
    }
    respond_to do |format|
      if (@version.title == "default") && (current_user.role != "administrator")
        format.html { redirect_to Song.find(song_id), alert: "O nome da cifra não pode ser \"default\" (nome reservado)" }
      elsif @version.update(version_params.merge(mandatory_params))
        format.html { redirect_to @version, notice: 'A cifra foi salva.' }
        # format.json { render :show, status: :ok, location: @version }
      else
        format.html { render :edit }
        # format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.json
  def destroy
    @version.destroy
    respond_to do |format|
      format.html { redirect_to request.referrer, notice: 'Cifra excluída.' }
      # format.json { head :no_content }
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
