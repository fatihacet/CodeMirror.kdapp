class CodeMirrorEditor extends KDObject
  
  constructor: (options = {}, data) ->
    
    super options, data
    
    options           = @getOptions()
    @lastSavedContent = null
    
    CodeMirror.modeURL = "https://#{nickname}.koding.com/.applications/codemirror/lib/codemirror/mode/%N/%N.js"
    
    CodeMirror.commands.autocomplete = (cm) ->
      CodeMirror.showHint cm, CodeMirror.javascriptHint
      
    @editor = CodeMirror options.container,
      tabSize                    : options.tabSize            or 2
      lineNumbers                : options.lineNumbers        or yes
      autofocus                  : options.autofocus          or yes
      theme                      : options.theme              or "ambiance"
      value                      : options.value              or ""
      styleActiveLine            : options.highlightLine      or yes
      highlightSelectionMatches  : options.highlightSelection or yes
      matchBrackets              : options.matchBrackets      or yes
      autoCloseBrackets          : options.closeBrackets      or yes
      autoCloseTags              : options.closeTags          or yes
      extraKeys                  : 
        "Ctrl-Space"             : "autocomplete"
        "Ctrl-Q"                 : => @fold
        "Cmd-S"                  : => @save()
        "Shift-Cmd-S"            : => @saveAs()
        "Alt-K"                  : => @moveFileToLeft()
        "Alt-L"                  : => @moveFileToRight()
        "Alt-T"                  : => @openEmptyFile()
        "Alt-W"                  : => @closeFile()
        "Shift-Alt-R"            : => @compileAndRunApp()
        "Shift-Alt-P"            : => @previewFile()
    
    # internal editor events
    @editor.on "cursorActivity", => 
      editorContainer = @getDelegate()
      applicationView = editorContainer.getDelegate()
      
      editorContainer.emit "CodeMirrorUpdateCaretPosition", @editor.getDoc().getCursor()
      applicationView.emit "CodeMirrorSetActiveTabView", applicationView.getOptions().tabView
      
    @editor.on "gutterClick", (a, b) => 
      CodeMirror.newFoldFunction(CodeMirror.braceRangeFinder) a, b
    
    # codemirror.kdapp events
    @on "CodeMirrorThemeChanged", (themeName) =>
      @updateTheme themeName
      
    @on "CodeMirrorModeChanged", (modeName) =>
      log "mode name is changing to", modeName
      @editor.setOption "mode", modeName
      CodeMirror.autoLoadMode @editor, modeName
      
    @fetchFileContent() unless @getData().path.match "localfile"
    
  save: ->
    content = @editor.getValue()
    return @notify "Nothing to save!" if content is @lastSavedContent
    
    file = @getData()
    return @saveAs() if file.path.match "localfile"
    
    file.save content, (err, res) => 
      return @notify "Couldn't save! Try again.", "success", 4000 if err
      @lastSavedContent = content
      @notify "Successfully saved!", "success", 4000
    
  saveAs: -> @showSaveAsDialog()
      
  fetchFileContent: ->
    file = @getData()
    file.fetchContents (err, content) =>
      @editor.setValue content
  
  getValue: -> return @editor.getValue()
      
  fold: ->
    # TODO: Need to change fold function for different file types
    CodeMirror.newFoldFunction(CodeMirror.braceRangeFinder) @editor, @editor.getCursor().line
    
  moveFileToLeft:  -> @getAppView().emit "CodeMirrorMoveFile", "left"
    
  moveFileToRight: -> @getAppView().emit "CodeMirrorMoveFile", "right"
    
  getAppView: ->
    editorContainer = @getDelegate()
    return codeMirrorView  = editorContainer.getDelegate()
  
  openEmptyFile: ->
    view = @getAppView()
    view.addNewTab view.activeTabView
    
  closeFile: ->
    view            = @getAppView()
    {activeTabView} = view
    activeTabView.removePane activeTabView.getActivePane()
    
  compileAndRunApp: ->
    manifest = KodingAppsController.getManifestFromPath @getData().path
    return @notify "You can only compile a kdapp.", "error" unless manifest
    
    kodingAppsController.compileApp manifest.name, (err) =>
      @notify "Trying to run old version..." if err 
      
      kodingAppsController.runApp manifest
  
  previewFile: ->
    publicUrlCheck = /.*\/(.*\.koding.com)\/website\/(.*)/
    publicPath = @getData().path.replace publicUrlCheck, 'http://$1/$2'
    return if publicPath is @getData().path
    
    appManager.openFileWithApplication publicPath, "Viewer"
    
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
  
  notify: (title, cssClass = "", duration = 3000, type = "mini") ->
    @notification.destroy() if @notification
    
    @notification = new KDNotificationView {
      type
      title
      duration
      cssClass
    }