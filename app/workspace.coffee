class CodeMirrorWorkspace extends Workspace

  constructor: (options = {}, data) ->

    options.panels      = [
      layout            :
        direction       : "vertical"
        sizes           : [ "100%", null ]
        splitName       : "BaseSplit"
        views           : [
          {
            type        : "custom"
            paneClass   : CodeMirrorEditorWrapper
            name        : "topLeftPane"
          }
          {
            type        : "custom"
            paneClass   : KDView
          }
        ]
    ]
    
    super options, data
