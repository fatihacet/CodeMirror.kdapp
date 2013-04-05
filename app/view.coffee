KD.enableLogs()
{nickname}           = KD.whoami().profile
windowController     = KD.getSingleton "windowController"
kiteController       = KD.getSingleton "kiteController"
kodingAppsController = KD.getSingleton "kodingAppsController"


class CodeMirrorView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror"
    
    super options, data
    
    @tabViews               = []
    @activeTabView          = null
    @isFirstTabViewVisible  = yes
    @isSecondTabViewVisible = no
    
    @splitView = new KDSplitView
      cssClass    : "codemirror-split-view"
      type        : "vertical"
      resizable   : yes
      animated    : no
      sizes       : [ "100%", null ]
      views       : [ @createNewTabView(), @createNewTabView() ]
    
    @splitView.on "viewAppended", =>
      @setSplitResizerVisibility()
      @addNewTab @getTabViewByIndex 0
      
    @on "CodeMirrorMoveFile", (direction) => 
      @moveFile direction
      @setSplitResizerVisibility yes
      
    @on "CodeMirrorSetActiveTabView", (tabView) =>
      @activeTabView = tabView
      
    [@activeTabView] = @tabViews
      
  moveFileHelper: (direction) ->
    activeTabView       = @activeTabView
    activeTabViewIndex  = @tabViews.indexOf activeTabView
    return if (direction is "right" and activeTabViewIndex is 1) or (direction is "left" and activeTabViewIndex is 0)
    activePane      = activeTabView.getActivePane()
    editorContainer = activePane.getOptions().editorContainer
    {editor}  = editorContainer
    content   = editor.getValue()
    file      = editorContainer.getData()
    
    activeTabView.removePane activePane
    targetIndex = if activeTabViewIndex is 0 then 1 else 0 
    targetTabView = @tabViews[targetIndex]
    @addNewTab targetTabView, file, content
    
    # hide empty view if activeTabView.getSubViews().length is 0
  
  moveFile: (direction) ->
    return @moveFileHelper direction if @isSecondTabViewVisible
    
    @splitView.resizePanel "50%", 1, => 
      @moveFileHelper direction
      @isSecondTabViewVisible = yes
  
  getTabViewByIndex: (index) -> return @tabViews[index]
  
  setSplitResizerVisibility: (shouldShow = no) ->
    methodName = if shouldShow then "show" else "hide"
    subViews   = @splitView.getSubViews()
    subView[methodName]() for subView in subViews when subView instanceof KDSplitResizer
    
  createNewTabView: ->
    holderView = new KDView
    
    holderView.addSubView tabHandleContainer = new ApplicationTabHandleHolder
      delegate: @
      
    dropTarget = new KDView
      cssClass  : "codemirror-drop-target"
      bind      : "dragstart dragend dragover drop dragenter dragleave"
      
    dropTarget.hide()
    
    holderView.addSubView tabView = new ApplicationTabView {
      delegate : @
      tabHandleContainer
      dropTarget
    }
    
    tabView.addSubView dropTarget
    
    @tabViews.push tabView
    
    dropTarget.on "drop", (e) =>
      file = FSHelper.createFileFromPath e.originalEvent.dataTransfer.getData "Text"
      @addNewTab tabView, file
    
    return holderView
  
  addNewTab: (tabView = @activeTabView, file, content) ->
    file = file or FSHelper.createFileFromPath 'localfile:/Untitled.txt'
    
    editorContainer = new CodeMirrorEditorContainer {
      delegate : @
      content
      tabView
    } , file
    
    pane = new KDTabPaneView
      name             : file.name or 'Untitled.txt'
      editorContainer  : editorContainer

    tabView.addPane pane
    pane.addSubView editorContainer
    
  viewAppended: ->
    super 
    
    KD.getSingleton("windowController").registerListener
      KDEventTypes : ["DragEnterOnWindow", "DragExitOnWindow"]
      listener : @
      callback : (pubInst, event) =>
        @dropTargetsCallback event
        
  dropTargetsCallback: (event) ->
    for tabView in @tabViews
      tabView.getOptions().dropTarget.show()
      tabView.getOptions().dropTarget.hide() if event.type is "drop"
    
  pistachio: -> """
    {{> @splitView}}
  """