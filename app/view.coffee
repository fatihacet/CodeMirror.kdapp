KD.enableLogs()
{nickname}       = KD.whoami().profile
windowController = KD.getSingleton "windowController"
kiteController   = KD.getSingleton "kiteController"


class CodeMirrorView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror"
    
    super options, data
    
    @tabViews            = []
    @isSecondPaneVisible = no
    
    @splitView = new KDSplitView
      cssClass    : "codemirror-split-view"
      type        : "vertical"
      resizable   : yes
      sizes       : [ "100%", null ]
      views       : [ @createNewTabView(), @createNewTabView() ]
    
    @splitView.on "viewAppended", =>
      @setSplitResizerVisibility()
      @addNewTab @getTabPaneByIndex 0
      @addNewTab @getTabPaneByIndex 0
      
    @on "CodeMirrorMoveFileToRight", =>
      @splitView.resizePanel "50%", 1, =>
        pane = @tabViews[0].getActivePane()
        debugger
        @tabViews[0].removePane pane
        
        # @addNewTab @tabViews[1], 
        
      @isSecondPaneVisible = yes
      
    @on "CodeMirrorMoveFileToLeft", =>
      log "to left"
  
  getTabPaneByIndex: (index) -> return @tabViews[index]
  
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
    
  addNewTab: (tabView, file) ->
    file = file or FSHelper.createFileFromPath 'localfile:/Untitled.txt'
    editorContainer = new CodeMirrorEditorContainer delegate: @, file
    
    pane = new KDTabPaneView
      name             : file.name or 'Untitled.txt'
      editorContainer  : editorContainer

    tabView.addPane pane
    pane.addSubView editorContainer
    
  pistachio: -> """
    {{> @splitView}}
  """