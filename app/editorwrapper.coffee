class CodeMirrorEditorWrapper extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-editor-container"
    
    super options, data
    
    @openedFiles         = {}
    
    @tabHandleContainer  = new ApplicationTabHandleHolder
      delegate           : this

    @tabView             = new ApplicationTabView
      delegate           : this
      tabHandleContainer : @tabHandleContainer
      
    @tabView.on "viewAppended", => @addNewTab()
    @tabView.on "PaneDidShow", (pane) ->
      appView.activeEditor = pane.editor
    
  saveAll: ->
    for pane in @tabView.panes when not pane.getData().path.match "localfile"
      pane.editor.save()
    
  openFile: (file) ->
    if @openedFiles[file.path]
      for pane, index in @tabView.panes when pane.getData() is file
        @tabView.showPaneByIndex index
    else
      @addNewTab file
  
  addNewTab: (fileNeedsToBeOpened) ->
    file        = fileNeedsToBeOpened or FSHelper.createFileFromPath "localfile://Untitled.txt"
    pane        = new KDTabPaneView    { name: file.name }, file
    pane.editor = new CodeMirrorEditor { pane, delegate: this }, file
    @openedFiles[file.path] = file
    @tabView.addPane pane
    pane.on "KDObjectWillBeDestroyed", =>
      delete @openedFiles[file.path]
      log @tabView.getActivePane().editor
      appView.activeEditor = @tabView.getActivePane().editor
  
  pistachio: ->
    """
      {{> @tabHandleContainer}}
      {{> @tabView}}
    """
    