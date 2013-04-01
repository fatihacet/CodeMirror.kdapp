class CodeMirrorEditor extends KDObject
  
  constructor: (options = {}, data) ->
    
    super options, data
    
    options = @getOptions()
    
    CodeMirror.modeURL = "https://#{nickname}.koding.com/.applications/codemirror/lib/codemirror/mode/%N/%N.js"
    
    CodeMirror.commands.autocomplete = (cm) ->
      CodeMirror.showHint cm, CodeMirror.javascriptHint
      
    @editor = CodeMirror options.container,
      tabSize                    : options.tabSize            or 2
      lineNumbers                : options.lineNumbers        or yes
      autofocus                  : options.autofocus          or yes
      theme                      : options.theme              or "ambiance"
      styleActiveLine            : options.highlightLine      or yes
      highlightSelectionMatches  : options.highlightSelection or yes
      value                      : options.value              or codeMirrorSettings.sampleCode
      matchBrackets              : options.matchBrackets      or yes
      autoCloseBrackets          : options.closeBrackets      or yes
      extraKeys                  : 
        "Ctrl-Space"             : "autocomplete"
        "Ctrl-Q"                 : => 
          log "fold called"
          CodeMirror.newFoldFunction(CodeMirror.braceRangeFinder) @editor, @editor.getCursor().line
        "D-D"                    : => console.log "dd"
        "Ctrl-S"                 : => console.log "ctrls"
        "Cmd-S"                  : => console.log "cmds"
        "Alt-S"                  : => console.log "alts"
        "Option-S"               : => console.log "options"
    
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
  
  updateTheme: (themeName) ->
    styleId   = "codemirror-theme-#{themeName}"
    return @editor.setOption "theme", themeName if document.getElementById styleId 
    
    command = "curl https://#{nickname}.koding.com/.applications/codemirror/lib/codemirror/theme/#{themeName}.css"
    kiteController.run command, (err, res) => 
      console.log "kite request started"
      style      = document.createElement "style"
      style.type = "text/css"
      style.id   = styleId
      
      if style.styleSheet
        style.styleSheet.cssText = res
      else 
        style.appendChild document.createTextNode res
      
      document.head.appendChild style
      
      console.log "style tag created"
      
      @editor.setOption "theme", themeName

      
      
      
      
      
      
      
      
      
      
    