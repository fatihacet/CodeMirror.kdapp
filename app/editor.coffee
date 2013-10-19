class CodeMirrorEditor extends KDView

  kodingAppsController = KD.getSingleton "kodingAppsController"
  vmController         = KD.getSingleton "vmController"
  {defaultVmName}      = vmController
  
  constructor: (options= {}, data) ->
    
    super options, data
    
    {@file}              = @getData()
    @fileExtension       = @file.getExtension()
    @container           = @getOptions().pane
    @lastSavedContent    = ""
    @appStorage          = KD.getSingleton("appStorageController").storage "CodeMirror", "1.0"
    CodeMirror.modeURL   = "https://koding-cdn.s3.amazonaws.com/codemirror/latest/mode/%N/%N.js"
    appView.activeEditor = @
    
    @appStorage.fetchStorage (storage) =>
      @createEditor()
      @bindEditorEvents()
      @container.on "viewAppended", =>
        {@tabHandle} = @getOptions().pane
        @createBottomBar()
        @doInternalResize_()
        
  createEditor: ->
    appStorage                  = @appStorage
    @editor                     = CodeMirror @container.getElement(),
      styleActiveLine           : appStorage.getValue("highlightLine")             or yes
      lineNumbers               : appStorage.getValue("lineNumbers")               or yes
      scrollPastEnd             : appStorage.getValue("scrollPastEnd")             or yes
      lineWrapping              : appStorage.getValue("lineWrapping")              or no
      tabSize                   : appStorage.getValue("tabSize")                   or 2
      fontSize                  : appStorage.getValue("fontSize")                  or 12
      highlightSelectionMatches : appStorage.getValue("highlightSelectionMatches") or showToken: /\w/
      matchBrackets             : appStorage.getValue("matchBrackets")             or yes # not optional yet
      autoCloseBrackets         : appStorage.getValue("autoCloseBrackets")         or yes # not optional yet
      showTrailingSpace         : appStorage.getValue("showTrailingSpace")         or no  # not optional yet
      undoDepth                 : appStorage.getValue("undoDepth")                 or 200 # not optional yet
      autofocus                 : appStorage.getValue("autofocus")                 or no  # there is a known issue so it's no until I fix it.
      gutters                   : [ "CodeMirror-linenumbers", "CodeMirror-foldgutter" ]
      foldGutter                : rangeFinder : new CodeMirror.fold.combine CodeMirror.fold.brace, CodeMirror.fold.comment, CodeMirror.fold.xml
      syntax                    : CodeMirrorSettings.syntaxHandlers[@fileExtension]  # it's not CM related it's for app logic
      extraKeys                 : 
        "Ctrl-Space"            : "autocomplete"
        "Cmd-S"                 : => @save()
        "Shift-Cmd-S"           : => @saveAs()
        "Cmd-Alt-S"             : => @saveAll()
        "Shift-Cmd-P"           : => @preview()
        "Shift-Cmd-C"           : => @compileAndRun()
        "Ctrl-G"                : => @goto()
        "Shift-Ctrl-1"          : => @moveFileHandler "left"
        "Shift-Ctrl-2"          : => @moveFileHandler "right"
        # TODO: Impelement CM find and replace with Search API.
        # "Cmd-F"               : => @showFindReplaceView no
        # "Shift-Cmd-F"         : => @showFindReplaceView yes
        
    unless @file.path.match "localfile"
      {content, position} = @getData()
      if content 
        @setContent content
        @markAsDirty no
        if position
          @editor.getDoc().setCursor
            line : position.line
            ch   : position.ch
          
          @editor.focus()
      else
        @fetchFileContent()
        
      @setSyntax()
    
    @setTheme appStorage.getValue("theme") or "lesser-dark"
    keyboardHandler = appStorage.getValue "keyboardHandler"
    switch keyboardHandler 
      when "vim"   then @setVimMode   yes
      when "emacs" then @setEmacsMode yes
      
    @editor.save      = => @save()
    @editor.quit      = => @quit()
    @editor.writeQuit = => @saveAndQuit()
    
    window.editor = @  if location.hostname is "localhost"
    
  showFindReplaceView: (openReplaceView) ->
    selectedText = "" # TODO: get the selected text
    @findAndReplaceView.setViewHeight openReplaceView
    @findAndReplaceView.setTextIntoFindInput selectedText
    @findAndReplaceView.on "FindAndReplaceViewClosed", => @focus()
    
  fetchFileContent: ->
    @file.fetchContents (err, contents) =>
      @notify "Could not fetch file content", "error"  if err
      @setContent contents
      @markAsDirty no
      
  save: (callback = noop) ->
    content = @editor.getValue()
    file    = @file
    
    return @notify "Nothing to save!"  if content is @lastSavedContent
    
    if file.path.match "localfile"
      return @notify "Nothing to save!"  if content is ""
      return @saveAs => callback()
    
    file.save content, (err, res) => 
      return @notify "Couldn't save! Please try again.", "error", 4000  if err
      @lastSavedContent = content
      @notify "Successfully saved!", "success", 4000
      @markAsDirty no
      callback()
    
  saveAs: (callback = noop) ->
    KD.utils.showSaveDialog @container, (input, finderController, dialog) =>
      [node] = finderController.treeController.selectedNodes
      name   = input.getValue()

      return @notify "Please type valid file name!"   , "error"  unless FSHelper.isValidFileName name
      return @notify "Please select a folder to save!", "error"  unless node

      dialog.destroy()
      file = FSHelper.createFileFromPath "#{node.getData().path}/#{input.getValue()}"
      file.save @editor.getValue(), (err, res) =>
        return @notify "Couldn't save! Please try again.", "error", 4000  if err
        @notify "Successfully saved.", "success", 4000
        @markAsDirty no
        callback()

    , { inputDefaultValue: @file.name }
    
  saveAll: ->
    @getDelegate().saveAll()
  
  saveAndQuit: ->
    @save => @quit()
  
  # in fact, name of this method should be closeCurrentTab.
  # quit is required by vim mode. 
  quit: -> 
    {tabView} = @getDelegate()
    tabView.removePane tabView.getActivePane()
    
  exit: ->
    appManager = KD.getSingleton "appManager"
    appManager.quit appManager.getFrontApp()
    
  setVimMode: (value) ->
    @editor.setOption "vimMode", value
  
  setEmacsMode: (value) ->
    {emacsy} = CodeMirror.keyMap
    if value then @editor.addKeyMap emacsy else @editor.removeKeyMap emacsy
    
  preview: ->
    {vmName, path} = @file
    KD.getSingleton("appManager").open "Viewer", params: { path, vmName }
    
  goto: (line, char) ->
    @gotoDialog ?= new CodeMirrorGotoDialog delegate: this  
  
  compileAndRun: ->
    manifest = KodingAppsController.getManifestFromPath @file.path
    return @notify "You can only compile a kdapp.", "error"  unless manifest
    
    appManager = KD.getSingleton "appManager"
    appManager.quitByName manifest.name

    kodingAppsController.compileApp manifest.name, (err) =>
      @ace.notify "Trying to run old version..."  if err
      appManager.open manifest.name
      
  bindEditorEvents: ->
    @listenWindowResize()
    
    @on "saveMenuItemClicked",           => @save()
    @on "saveAsMenuItemClicked",         => @saveAs()
    @on "saveAllMenuItemClicked",        => @saveAll()
    @on "findMenuItemClicked",           => CodeMirror.commands.find @editor
    @on "findAndReplaceMenuItemClicked", => CodeMirror.commands.replace @editor
    @on "gotoMenuItemClicked",           => @goto()
    @on "compileAndRunMenuItemClicked",  => @compileAndRun()
    @on "previewMenuItemClicked",        => @preview()
    @on "quitMenuItemClicked",           => @quit()
    @on "exitMenuItemClicked",           => @exit()
    
    @on "CodeMirrorSettingsChanged", (key, value) =>
      @updateSettings key, value
    
    @editor.on "cursorActivity", => 
      @updateCaretPos @editor.getDoc().getCursor()
    
    @editor.on "change", =>
      @markAsDirty @editor.getValue() isnt @lastSavedContent
      appView.activeEditor = @
    
    @editor.on "mousedown", =>
      appView.activeEditor = @
      
    CodeMirror.commands.autocomplete = (cm) ->
      handler = CodeMirrorSettings.autocompleteHandlers[@fileExtension] or "anyword"
      CodeMirror.showHint cm, CodeMirror.hint[handler]
      
  updateSettings: (key, value) ->
    methodMap         = 
      theme           : "setTheme"
      syntax          : "setSyntax"
      layout          : "updateLayout"
      keyboardHandler : "enableKeyboardHandler"
      tabSize         : "setTabSize"
      fontSize        : "setFontSize"
      lineNumbers     : "setLineNumbers"
      useWordWrap     : "setWordWrap"
      highlightLine   : "setHighlightLine"
      scrollPastEnd   : "setScrollPastEnd"
      highlightSelectionMatches : "setHighlightSelectionMatches"
    
    methodName = methodMap[key]
    if methodName 
      @[methodName] value
      @appStorage.setValue key, value
    else
      warn "Unhandled CM option", key, value
      
  setContent: (content) ->
    @editor.setValue content
      
  markAsDirty: (isDirty) ->
    return unless @tabHandle
    methodName = if isDirty  then "setClass" else "unsetClass"
    @tabHandle[methodName] "modified"
    
  setSyntax: (syntaxName) ->
    unless syntaxName
      extension = @fileExtension
      slug      = CodeMirrorSettings.syntaxHandlers[extension] or extension

    mode        = syntaxName or slug
    @editor.setOption "mode", mode
    CodeMirror.autoLoadMode @editor, mode
    
  updateLayout: (type) ->
    @getDelegate().emit "UpdateLayout", type
    
  setLineNumbers: (value) ->
    @editor.setOption "lineNumbers", value
    
  setWordWrap: (value) ->
    @editor.setOption "lineWrapping", value
  
  setHighlightLine: (value) ->
    @editor.setOption "styleActiveLine", value
    
  setHighlightSelectionMatches: (value) ->
    value = if value then showToken : /\w/ else no
    @editor.setOption "highlightSelectionMatches", value
    
  setScrollPastEnd: (value) ->
    @editor.setOption "scrollPastEnd", value
    
  updateCaretPos: (posObj) ->
    @caretPos.updatePartial "Line #{posObj.line + 1}, Column #{posObj.ch + 1}"
  
  createBottomBar: ->
    @bottomBar = new KDCustomHTMLView
      cssClass : "editor-bottom-bar"
      
    @caretPos  = new KDCustomHTMLView
      tagName  : "span"
      cssClass : "caret-position section"
      partial  : "Line 1, Column 1"
    
    @filePath  = new KDCustomHTMLView
      tagName  : "span"
      cssClass : "file-path section"
      partial  : FSHelper.plainPath @file.path.replace("localfile://", "").replace("/home/#{KD.nick()}", "~")
      
    @bottomBar.addSubView @caretPos
    @bottomBar.addSubView @filePath
    
    @findAndReplaceView = new CodeMirrorFindAndReplaceView delegate: this
    @findAndReplaceView.hide()
    @container.addSubView @findAndReplaceView
    
    @container.addSubView @bottomBar
    
  getAdvancedSettingsMenuView: ->
    new CodeMirrorAdvancedSettingsView delegate: this
    
  enableKeyboardHandler: (handler) ->
    switch handler
      when "vim"      then @setVimMode   yes
      when "emacs"    then @setEmacsMode yes
      when "default"
        @setVimMode   no
        @setEmacsMode no
        
  setFontSize: (size) ->
    @editor.display.wrapper.style.fontSize = "#{size}px"
    
  setTheme: (themeName) ->
    styleId = "codemirror-theme-#{themeName}"
    
    if document.getElementById styleId 
      return @editor.setOption "theme", themeName
    
    command = "curl -kLs https://koding-cdn.s3.amazonaws.com/codemirror/latest/theme/#{themeName}.css"
    
    @doKiteRequest command, (err, res) => 
      style      = document.createElement "style"
      style.type = "text/css"
      style.id   = styleId
      
      if style.styleSheet 
        style.styleSheet.cssText = res
      else 
        style.appendChild document.createTextNode res
      
      document.head.appendChild style
      @editor.setOption "theme", themeName
      
  setTabSize: (size) ->
    @editor.setOption "tabSize", size
    
  moveFileHandler: (direction) ->
    wrapper   = @getDelegate()
    {region}  = wrapper.getOptions()
    return if (region is "topLeft" and direction is "left") or (region is "topRight" and direction is "right")
    
    editor    = @editor
    content   = editor.getValue()
    position  = editor.getDoc().getCursor()
    workspace = wrapper.panel.getDelegate()
    argsObj   = { workspace, region, @file, content, position }
      
    if workspace.currentLayout isnt "vertical"
      workspace.toggleView "vertical", => @moveFileHelper argsObj
    else
      @moveFileHelper argsObj
    
  moveFileHelper: (argsObj) ->
    {tabView}        = @getOptions()
    tabView.removePane tabView.getActivePane()
    targetWrapperKey = if argsObj.region is "topLeft" then "topRightPane" else "topLeftPane"
    targetPane       = argsObj.workspace.getActivePanel().getPaneByName targetWrapperKey
    targetPane.addNewTab argsObj.file, argsObj.content, argsObj.position
  
  _windowDidResize: ->
    @doInternalResize_()
  
  doInternalResize_: ->
    @utils.defer =>
      @editor.setSize "100%", @container.getHeight() - 44 # 44 is top and bottom bars
      
  notify: (title, cssClass = "", duration = 3000, type = "mini") ->
    @notification.destroy()  if @notification
    @notification = new KDNotificationView { type, title, duration, cssClass }
    
  defaultErrorNotify: ->
    @notify "An error occured. Please try again!", "error", 4000
    
  doKiteRequest: (command, callback = noop, vmName = defaultVmName) ->
    vmController.run
      withArgs  : command
      vmName    : vmName
    , (err, res) =>
      return @defaultErrorNotify()  if err
      callback err, res
