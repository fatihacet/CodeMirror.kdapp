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
            name        : "topLeftPane"
            region      : "topLeft"
            paneClass   : CodeMirrorEditorWrapper
          }
          {
            type        : "custom"
            name        : "topRightPane"
            region      : "topRight"
            paneClass   : CodeMirrorEditorWrapper
          }
        ]
    ]
    
    super options, data
    
    window.workspace = @  if location.hostname is "localhost"
    @currentLayout   = "single"
  
  toggleView: (type, callback = noop) ->
    switch type
      when "vertical"
        splitView      = @getActivePanel().layoutContainer.getSplitByName "BaseSplit"
        @currentLayout = "vertical"
        
        splitView.resizePanel "50%", 0, => callback @, splitView

      when "horizontal" or "grid"
        new KDNotificationView
          type     : "mini"
          title    : "This feature will be implemented soon"
          duration : 6000
