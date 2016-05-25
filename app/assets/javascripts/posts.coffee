# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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
  r = confirm("이미지 파일도 함께 삭제하시겠습니까?")
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
        # onKeyup: (e) ->
        #   if e.keyCode == 46 or e.keyCode == 8
        #     console.log 'Delete Key Pressed'
        #   return
  return
