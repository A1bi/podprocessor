window.addEventListener 'load', ->
  body = document.querySelector('body')
  metadata = document.querySelectorAll '.metadata'
  filepicker = document.querySelector '#audio-file'
  return unless filepicker?

  setProcessingState = (state) ->
    body.classList.remove 'processing', 'processed'
    body.classList.add state if state?
    input.disabled = state == 'processing' for input in metadata

  FilePond.registerPlugin(FilePondPluginFileValidateType)

  pond = FilePond.create(filepicker,
    name: 'file',
    labelIdle: filepicker.dataset.label
    acceptedFileTypes: ['audio/mpeg', 'audio/mp3',
                        'audio/vnd.wave', 'audio/wav', 'audio/wave', 'audio/x-wav'],
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
    setProcessingState if error? then null else 'processed'

  pond.on 'processfileabort', ->
    setProcessingState
