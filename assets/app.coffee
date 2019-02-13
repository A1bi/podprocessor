window.addEventListener 'load', ->
  body = document.querySelector('body')
  filepicker = document.querySelector '#audio-file'
  metadata = document.querySelectorAll '.metadata'

  setProcessingState = (state) ->
    body.classList.remove 'processing', 'processed'
    body.classList.add state if state?
    input.disabled = state == 'processing' for input in metadata

  FilePond.registerPlugin(FilePondPluginFileValidateType)

  pond = FilePond.create(filepicker,
    name: 'file',
    labelIdle: filepicker.dataset.label
    acceptedFileTypes: ['audio/mpeg', 'audio/mp3'],
    server: {
      url: '/files',
      process: {
        ondata: (formData) ->
          formData.append(input.name, input.value) for input in metadata
          return formData
      }
    }
  )

  pond.on 'processfilestart', ->
    setProcessingState 'processing'

  pond.on 'processfile', (error) ->
    setProcessingState if error? then '' else 'processed'

  pond.on 'processfileabort', ->
    setProcessingState
