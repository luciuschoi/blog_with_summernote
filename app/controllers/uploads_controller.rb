class UploadsController < ApplicationController
  # protect_from_forgery except: :create

  def create
    @upload = Upload.new(upload_params)
    @upload.save

    respond_to do |format|
      format.json { render :json => { url: @upload.image.url } }
    end
  end

  def destroy
    upload_id = params[:file_name].split('/')[-3].to_i
    @uploaded_file = Upload.find(upload_id)
    if @uploaded_file.destroy
      respond_to do |format|
        format.json { render :json => { deleted_file: params[:file_name] } }
      end
    else

    end
  end

  private

  def upload_params
    params.require(:upload).permit(:image, :image_file_name, :image_content_type, :image_file_size, :image_updated_at)
  end
end
