class CodeMirrorEditorWrapper extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-editor-container"
    
    super options, data
    
    @openedFiles         = {}
    @panel               = @getDelegate()
    
    @tabHandleContainer  = new ApplicationTabHandleHolder
      delegate           : this

    @tabView             = new ApplicationTabView
      delegate           : this
      tabHandleContainer : @tabHandleContainer
      closeAppWhenAllTabsClosed: no
      
    @tabView.on "viewAppended", =>
      @addNewTab()
      @panel.tabViews = [] unless @panel.tabViews
      @panel.tabViews.push @tabView
      
    @tabView.on "PaneDidShow", (pane) ->
      appView.activeEditor = pane.editor
      
    @on "UpdateLayout", (type) =>
      panel     = @getDelegate()
      workspace = panel.getDelegate()
      workspace.toggleView type
      
  saveAll: ->
    for pane in @tabView.panes when not pane.getData().path.match "localfile"
      pane.editor.save()
    
  openFile: (file) ->
    if @openedFiles[file.path]
      for pane, index in @tabView.panes when pane.getData() is file
        @tabView.showPaneByIndex index
    else
      @addNewTab file
  
  addNewTab: (fileNeedsToBeOpened, content, position) ->
    file        = fileNeedsToBeOpened or FSHelper.createFileFromPath "localfile://Untitled.txt"
    pane        = new KDTabPaneView    { name: file.name }, file
    pane.editor = new CodeMirrorEditor { pane, @tabView, delegate: this }, { file, content, position }
    @openedFiles[file.path] = file
    @tabView.addPane pane
    pane.on "KDObjectWillBeDestroyed", =>
      delete @openedFiles[file.path]
      appView.activeEditor = @tabView.getActivePane().editor
  
  pistachio: ->
    """
      {{> @tabHandleContainer}}
      {{> @tabView}}
    """
    