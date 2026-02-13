module AdminArea
  class EpisodesController < BaseController
    before_action :set_subscription_plan
    before_action :set_episode, only: %i[edit update destroy move_up move_down destroy_cover_image destroy_media destroy_video destroy_audio destroy_attachment]
    before_action :load_media_assets, only: %i[new edit create update]

    def new
      @episode = @subscription_plan.episodes.new
      authorize @episode
    end

    def create
      @episode = @subscription_plan.episodes.new(episode_params.except(:attachments))
      authorize @episode
      attach_files(@episode)
      if @episode.save
        sync_media_library!(@episode)
        redirect_to admin_subscription_plan_path(@subscription_plan), notice: "Epizoda vytvořena."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @episode
    end

    def update
      authorize @episode
      @episode.assign_attributes(episode_params.except(:attachments))
      attach_files(@episode)

      if @episode.save
        sync_media_library!(@episode)
        redirect_to admin_subscription_plan_path(@subscription_plan), notice: "Epizoda upravena."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @episode
      @episode.destroy!
      redirect_to admin_subscription_plan_path(@subscription_plan), notice: "Epizoda smazána."
    end

    def move_up
      authorize @episode
      @episode.move_up!
      respond_to_reorder
    end

    def move_down
      authorize @episode
      @episode.move_down!
      respond_to_reorder
    end

    def destroy_cover_image
      authorize @episode
      @episode.cover_image.purge if @episode.cover_image.attached?
      redirect_to edit_admin_subscription_plan_episode_path(@subscription_plan, @episode), notice: "Náhled smazán."
    end

    def destroy_media
      authorize @episode
      @episode.media.purge if @episode.media.attached?
      redirect_to edit_admin_subscription_plan_episode_path(@subscription_plan, @episode), notice: "Médium smazáno."
    end

    def destroy_video
      authorize @episode
      @episode.video.purge if @episode.video.attached?
      redirect_to edit_admin_subscription_plan_episode_path(@subscription_plan, @episode), notice: "Video smazáno."
    end

    def destroy_audio
      authorize @episode
      @episode.audio.purge if @episode.audio.attached?
      redirect_to edit_admin_subscription_plan_episode_path(@subscription_plan, @episode), notice: "Audio smazáno."
    end

    def destroy_attachment
      authorize @episode
      attachment = @episode.attachments.attachments.find(params[:attachment_id])
      attachment.purge
      redirect_to edit_admin_subscription_plan_episode_path(@subscription_plan, @episode), notice: "Příloha smazána."
    end

    private

    def set_subscription_plan
      @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id])
    end

    def set_episode
      @episode = @subscription_plan.episodes.find(params[:id])
    end

    def episode_params
      params.require(:episode).permit(:title, :status, :content, :cover_image, :media, :video, :audio, :video_asset_id, :cover_asset_id, :audio_asset_id, :published_at, attachments: [])
    end

    def attach_files(episode)
      new_files = Array(episode_params[:attachments]).reject(&:blank?)
      episode.attachments.attach(new_files) if new_files.any?
    end

    def load_media_assets
      @video_assets = MediaAsset.where(media_type: "video").order(created_at: :desc)
      @image_assets = MediaAsset.where(media_type: "image").order(created_at: :desc)
      @audio_assets = MediaAsset.where(media_type: "audio").order(created_at: :desc)
    end

    def sync_media_library!(episode)
      if episode.video.attached?
        if episode.video_asset.blank? || episode.video_asset.file.blob_id != episode.video.blob_id
          asset = MediaAsset.create!(title: episode.video.filename.to_s, media_type: "video", file: episode.video.blob)
          episode.update_column(:video_asset_id, asset.id)
        end
      end

      if episode.cover_image.attached?
        if episode.cover_asset.blank? || episode.cover_asset.file.blob_id != episode.cover_image.blob_id
          asset = MediaAsset.create!(title: episode.cover_image.filename.to_s, media_type: "image", file: episode.cover_image.blob)
          episode.update_column(:cover_asset_id, asset.id)
        end
      end

      if episode.audio.attached?
        if episode.audio_asset.blank? || episode.audio_asset.file.blob_id != episode.audio.blob_id
          asset = MediaAsset.create!(title: episode.audio.filename.to_s, media_type: "audio", file: episode.audio.blob)
          episode.update_column(:audio_asset_id, asset.id)
        end
      end
    end

    def respond_to_reorder
      @subscription_plan.episodes.reload
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("episodes_list", partial: "admin_area/subscription_plans/episodes_list", locals: { subscription_plan: @subscription_plan }) }
        format.html { redirect_to admin_subscription_plan_path(@subscription_plan) }
      end
    end
  end
end
