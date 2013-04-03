class CodeMirrorEditor extends KDObject
  
  constructor: (options = {}, data) ->
    
    super options, data
    
    options  = @getOptions()
    
    CodeMirror.modeURL = "https://#{nickname}.koding.com/.applications/codemirror/lib/codemirror/mode/%N/%N.js"
    
    CodeMirror.commands.autocomplete = (cm) ->
      CodeMirror.showHint cm, CodeMirror.javascriptHint
      
    @editor = CodeMirror options.container,
      tabSize                    : options.tabSize            or 2
      lineNumbers                : options.lineNumbers        or yes
      autofocus                  : options.autofocus          or yes
      theme                      : options.theme              or "ambiance"
      value                      : options.value              or codeMirrorSettings.sampleCode
      styleActiveLine            : options.highlightLine      or yes
      highlightSelectionMatches  : options.highlightSelection or yes
      matchBrackets              : options.matchBrackets      or yes
      autoCloseBrackets          : options.closeBrackets      or yes
      autoCloseTags              : options.closeTags          or yes
      extraKeys                  : 
        "Ctrl-Space"             : "autocomplete"
        "Ctrl-Q"                 : => @fold
        "Alt-O"                  : => @moveFileToLeft()
        "Alt-P"                  : => @moveFileToRight()
    
    # internal editor events
    @editor.on "cursorActivity", => 
      @getDelegate().bottomBar.updateCaretPos @editor.doc.getCursor()
      
    @editor.on "gutterClick", (a, b) => 
      CodeMirror.newFoldFunction(CodeMirror.braceRangeFinder) a, b
    
    # codemirror.kdapp events
    @on "CodeMirrorThemeChanged", (themeName) =>
      @updateTheme themeName
      
    @on "CodeMirrorModeChanged", (modeName) =>
      log "mode name is changing to", modeName
      @editor.setOption "mode", modeName
      CodeMirror.autoLoadMode @editor, modeName
      
  fold: ->
    CodeMirror.newFoldFunction(CodeMirror.braceRangeFinder) @editor, @editor.getCursor().line
    
  moveFileToLeft: -> @getAppView().emit "CodeMirrorMoveFileToLeft"
    
  moveFileToRight: -> @getAppView().emit "CodeMirrorMoveFileToRight"
    
  getAppView: ->
    editorContainer = @getDelegate()
    codeMirrorView  = editorContainer.getDelegate()
    return codeMirrorView
  
  updateTheme: (themeName) ->
    styleId   = "codemirror-theme-#{themeName}"
    return @editor.setOption "theme", themeName if document.getElementById styleId 
    
    command = "curl https://#{nickname}.koding.com/.applications/codemirror/lib/codemirror/theme/#{themeName}.css"
    kiteController.run command, (err, res) => 
      log "kite request started"
      style      = document.createElement "style"
      style.type = "text/css"
      style.id   = styleId
      
      if style.styleSheet
        style.styleSheet.cssText = res
      else 
        style.appendChild document.createTextNode res
      
      document.head.appendChild style
      
      log "style tag created"
      
      @editor.setOption "theme", themeName
      