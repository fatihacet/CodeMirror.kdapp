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
            paneClass   : CodeMirrorEditorWrapper
          }
          {
            type        : "custom"
            name        : "topRightPane"
            paneClass   : KDView
          }
        ]
    ]
    
    super options, data
    
    window.workspace = @  if location.hostname is "localhost"
    
  toggleView: (type) ->
    switch type
      when "vertical"
        activePanel = @getActivePanel()
        activePanel.layoutContainer.getSplitByName("BaseSplit").resizePanel "50%", 0
        activePanel.getPaneByName("topRightPane").addSubView new CodeMirrorEditorWrapper