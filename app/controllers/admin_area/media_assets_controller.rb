module AdminArea
  class MediaAssetsController < BaseController
    before_action :set_media_asset, only: %i[edit update destroy]

    def index
      @media_assets = MediaAsset.includes(video_segments: { chapter: :course }, cover_segments: { chapter: :course }).order(created_at: :desc)
    end

    def new
      @media_asset = MediaAsset.new
    end

    def create
      @media_asset = MediaAsset.new(media_asset_params)
      if @media_asset.save
        redirect_to admin_media_assets_path, notice: "Média uložena."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @media_asset.update(media_asset_params)
        redirect_to admin_media_assets_path, notice: "Média upravena."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @media_asset.destroy!
      redirect_to admin_media_assets_path, notice: "Média smazána."
    end

    private

    def set_media_asset
      @media_asset = MediaAsset.find(params[:id])
    end

    def media_asset_params
      params.require(:media_asset).permit(:title, :media_type, :notes, :file)
    end
  end
end
