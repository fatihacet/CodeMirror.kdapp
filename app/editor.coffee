class CodeMirrorEditor extends KDView

  kodingAppsController = KD.getSingleton "kodingAppsController"
  vmController         = KD.getSingleton "vmController"
  {defaultVmName}      = vmController
  
  constructor: (options= {}, data) ->
    
    super options, data
    
    @file              = @getData()
    @fileExtension     = @file.getExtension()
    @container         = @getOptions().pane
    @lastSavedContent  = ""
    CodeMirror.modeURL = "https://koding-cdn.s3.amazonaws.com/codemirror/latest/mode/%N/%N.js"
    
    @createEditor()
    @bindEditorEvents()
    @container.on "viewAppended", =>
      {@tabHandle} = @getOptions().pane
      @createBottomBar()
      @doInternalResize_()

  createEditor: ->
    @editor             = CodeMirror @container.getElement(),
      lineNumbers       : yes
      autofocus         : yes
      tabSize           : 2
      theme             : "ambiance"
      styleActiveLine   : yes
      extraKeys         : 
        "Ctrl-Space"    : "autocomplete"
        "Cmd-S"         : => @save()
        "Shift-Cmd-S"   : => @saveAs()
        "Shift-Cmd-P"   : => @preview()
        "Shift-Cmd-C"   : => @compileAndRun()
        "Cmd-F"         : => @showFindReplaceView no
        "Shift-Cmd-F"   : => @showFindReplaceView yes
        "Ctrl-G"        : => @goto()
        
    unless @file.path.match "localfile"
      @fetchFileContent()
      @setSyntax()
      
    window.editor = @
      
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
      
  save: ->
    content = @editor.getValue()
    file    = @getData()
    
    return @notify "Nothing to save!"  if content is @lastSavedContent
    
    if file.path.match "localfile"
      return @notify "Nothing to save!"  if content is ""
      return @saveAs() 
    
    file.save content, (err, res) => 
      return @notify "Couldn't save! Please try again.", "error", 4000  if err
      @lastSavedContent = content
      @notify "Successfully saved!", "success", 4000
      @markAsDirty no
    
  saveAs: ->
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

    , { inputDefaultValue: @getData().name }
    
  preview: ->
    {vmName, path} = @getData()
    KD.getSingleton("appManager").open "Viewer", params: { path, vmName }
    
  goto: (line, char) ->
    @gotoDialog ?= new CodeMirrorGotoDialog delegate: this  
  
  compileAndRun: ->
    manifest = KodingAppsController.getManifestFromPath @getData().path
    return @notify "You can only compile a kdapp.", "error"  unless manifest
    
    appManager = KD.getSingleton "appManager"
    appManager.quitByName manifest.name

    kodingAppsController.compileApp manifest.name, (err) =>
      @ace.notify "Trying to run old version..."  if err
      appManager.open manifest.name
  
  bindEditorEvents: ->
    @listenWindowResize()
    
    @editor.on "cursorActivity", => 
      @updateCaretPos @editor.getDoc().getCursor()
    
    @editor.on "change", =>
      @markAsDirty @editor.getValue() isnt @lastSavedContent
      
    CodeMirror.commands.autocomplete = (cm) ->
      handler = CodeMirrorSettings.autocompleteHandlers[@fileExtension] or "anyword"
      CodeMirror.showHint cm, CodeMirror.hint[handler]
      
  setContent: (content) ->
    @editor.setValue content
      
  markAsDirty: (isDirty) ->
    methodName = if isDirty  then "setClass" else "unsetClass"
    @tabHandle[methodName] "modified"
    
  setSyntax: ->
    extension = @fileExtension
    slug      = CodeMirrorSettings.syntaxHandlers[extension] or extension
    @editor.setOption "mode", slug
    CodeMirror.autoLoadMode @editor, slug
    
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
      partial  : @getData().path
      
    @bottomBar.addSubView @caretPos
    @bottomBar.addSubView @filePath
    
    @findAndReplaceView = new CodeMirrorFindAndReplaceView delegate: this
    @findAndReplaceView.hide()
    @container.addSubView @findAndReplaceView
    
    @container.addSubView @bottomBar
    
  _windowDidResize: ->
    @doInternalResize_()
  
  doInternalResize_: ->
    @utils.defer =>
      @editor.setSize "100%", @container.getHeight() - 44 # top and bottom bars
      
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
      callback()
      