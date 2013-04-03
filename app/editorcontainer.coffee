class CodeMirrorEditorContainer extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-editor-container"
    
    super options, data
    
    @editor       = null # will be set at viewAppended
    
    @topBar       = new CodeMirrorTopBar
      
    @container    = new KDView
      cssClass    : "codemirror-editor"

    @bottomBar    = new CodeMirrorBottomBar
      delegate    : @
    
    @settingsView = new CodeMirrorSettingsView
      delegate    : @
    
    @settingsView.hide()
    
    @findAndReplaceView = new KDView
  
  viewAppended: ->
    super
    
    @editor = window.editor = new CodeMirrorEditor
      container : @container.getDomElement()[0]
      delegate  : @
    @resize()
    
  resize: ->
    # 90 = appViewPadding is 10, topBarHeight is 38, bottomBarHeight is 21, appTabsHeight is 21
    @container.setHeight appView.getHeight() - 90
    
  pistachio: -> """
    {{> @topBar}}
    {{> @container}}
    {{> @bottomBar}}
    {{> @findAndReplaceView}} 
    {{> @settingsView}}
  """