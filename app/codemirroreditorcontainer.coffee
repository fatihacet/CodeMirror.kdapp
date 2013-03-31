class CodeMirrorEditorContainer extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-editor-container"
    
    super options, data
    
  viewAppended: ->
    super
    @resize()
    
  resize: ->
    appViewPadding  = 10 # should removed when css are working
    topBarHeight    = 38
    bottomBarHeight = 21
    
    @setHeight appView.getHeight() - topBarHeight - bottomBarHeight - appViewPadding