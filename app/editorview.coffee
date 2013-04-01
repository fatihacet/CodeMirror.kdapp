KD.enableLogs()
{nickname}       = KD.whoami().profile
windowController = KD.getSingleton "windowController"
kiteController   = KD.getSingleton "kiteController"


class CodeMirrorEditorView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror"
    
    super options, data
    
    @editor    = null # will be set at viewAppended
    
    @topBar    = new CodeMirrorTopBar
      
    @container = new CodeMirrorEditorContainer

    @bottomBar = new CodeMirrorBottomBar
      delegate: @
    
    @settingsView = new CodeMirrorSettingsView
      delegate: @
    
    @settingsView.hide()
    
    @findAndReplaceView = new KDView
    
  viewAppended: ->
    super
    @editor = window.editor = new CodeMirrorEditor
      container : @container.getDomElement()[0]
      delegate  : @
    
  pistachio: -> """
    {{> @topBar}}
    {{> @container}}
    {{> @bottomBar}}
    {{> @findAndReplaceView}} 
    {{> @settingsView}}
  """