KD.enableLogs()
{nickname}       = KD.whoami().profile
windowController = KD.getSingleton "windowController"
kiteController   = KD.getSingleton "kiteController"


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
      sizes       : [ "100%", null ]
      views       : [ @createNewTabView(), @createNewTabView() ]
    
    @splitView.on "viewAppended", =>
      @setSplitResizerVisibility()
      @addNewTab @getTabViewByIndex 0
      @addNewTab @getTabViewByIndex 0
      @addNewTab @getTabViewByIndex 0
      @addNewTab @getTabViewByIndex 0
      @addNewTab @getTabViewByIndex 0
      @addNewTab @getTabViewByIndex 0
      @addNewTab @getTabViewByIndex 0
      
    @on "CodeMirrorMoveFile", (direction) => 
      @moveFile direction
      @setSplitResizerVisibility yes
      
    @on "CodeMirrorSetActiveTabView", (tabView) =>
      @activeTabView = tabView
      
  moveFileHelper: (direction) ->
    activeTabView   = @activeTabView
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

    holderView.addSubView tabView = new ApplicationTabView {
      delegate : @
      tabHandleContainer   
    }
      
    @tabViews.push tabView
    
    return holderView
  
  addNewTab: (tabView, file, content) ->
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
    
  pistachio: -> """
    {{> @splitView}}
  """