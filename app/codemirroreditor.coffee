KD.enableLogs()

class CodeMirrorEditor extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror"
    
    super options, data
    
    @editor    = null # will be set at viewAppended
    
    @topBar    = new CodeMirrorTopBar
      
    @container = new CodeMirrorEditorContainer

    @bottomBar = new CodeMirrorBottomBar
    
  viewAppended: ->
    super
    @editor = window.editor = CodeMirror @container.getDomElement()[0],
      tabSize        : 2
      lineNumbers    : yes
      autofocus      : yes
      theme          : "ambiance"
      
    @editor.on "cursorActivity", => @bottomBar.updateCaretPos @editor.doc.getCursor()
    
  pistachio: -> """
    {{> @topBar}}
    {{> @container}}
    {{> @bottomBar}}
  """