# Blog Demo Application with Summernote 8 WYSIWYG Web Editor

- Ruby 2.3.1
- Rails 5.0.0.rc1
- Summernote-rails v 0.8.1.1

In `Gemfile`, you will need the following gems.

```ruby
gem 'bootstrap-sass'
gem "bootstrap_flash_messages", "~> 1.0.1"
gem 'font-awesome-sass'
gem 'summernote-rails', '0.8.1.1'
gem 'codemirror-rails'
gem 'simple_form'
gem 'paperclip'
```

You may rename application.css to application.scss, and so,  `app/assets/stylesheets/application.scss` will look like this:

```scss
@import "bootstrap";
@import "scaffolds";
@import "font-awesome-sprockets";
@import "font-awesome";
@import "codemirror";
@import "codemirror/themes/monokai";
@import "summernote";
@import "posts"
```

Main important scripts on summernote can be written in `app/assets/javaScripts/posts.coffee` or any other coffeescript file.

```coffeescript
sendFile = (file, toSummernote) ->
  data = new FormData
  data.append 'upload[image]', file
  $.ajax
    data: data
    type: 'POST'
    url: '/uploads'
    cache: false
    contentType: false
    processData: false
    success: (data) ->
      console.log 'file uploading...' + data.url.split("?")[0]
      toSummernote.summernote "insertImage", data.url

deleteFile = (file) ->
  parser = document.createElement('a')
  parser.href = file
  file_name = parser.pathname
  r = confirm("Would you like to delete the uploaded image file?")
  if r == true
    $.ajax
      url: '/delete_file'
      type: 'DELETE'
      data:
        file_name: file_name
      success: (data) ->
        console.log "file deleting..." + data.deleted_file
        # delete imageNode
        return
      error: ->
        console.log "errors on file deletion"
        # do something
        return
  return


# For Rails 5 (Turbolinks 5) page:load becomes turbolinks:load and will be even fired on initial load.
$(document).on 'turbolinks:load', ->
  $('[data-provider="summernote"]').each ->
    $(this).summernote
      lang: 'ko-KR'
      height: 500
      codemirror:
        lineWrapping: true
        lineNumbers: true
        tabSize: 2
        theme: 'monokai'
      callbacks:
        onImageUpload: (files) ->
          sendFile files[0], $(this)
        onMediaDelete: ($target, editor, $editable) ->
          deleteFile $target[0].src
  return
```

`Upload` model class is generated as follows:

```sh
$ rails g model Upload
```

Using Paperclip generator, `image` attribute is added to `Upload` model class as follows:

```sh
$ rails g paperclip Upload image
```

And then, you rake db:migrate for the migration class generated.

In `app/models/upload.rb`, `Upload` class will be as follows:


```ruby
class Upload < ActiveRecord::Base
  has_attached_file :image
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
```

`uploads` controller is generated including `create` and `destroy` actions.

```sh
$ rails g controller uploads create destroy
```

In `app/controllers/uploads_controller.rb`, `uploads` controller will be as follows:

```ruby
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
    @uploaded_file.destroy

    respond_to do |format|
      format.json { render :json => { deleted_file: params[:file_name] } }
    end
  end

  private

  def upload_params
    params.require(:upload).permit(:image, :image_file_name, :image_content_type, :image_file_size, :image_updated_at)
  end
end

```

In `config/routes.rb`, you should declare routes as follows:


```ruby
Rails.application.routes.draw do
  root "posts#index"
  resources :posts
  post 'uploads' => 'uploads#create'
  delete 'delete_file' => 'uploads#destroy'
end
```

> **Note**: Demo screencasts is uploaded on youtube https://youtu.be/_mUu6CIBuqw.
