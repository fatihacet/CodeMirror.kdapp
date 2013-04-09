CodeMirrorEditor::showSaveAsDialog = ->
  file = @getData()
  
  @saveAsDialog = new KDDialogView
    cssClass      : "save-as-dialog"
    duration      : 200
    topOffset     : 0
    overlay       : yes
    height        : "auto"
    buttons       :
      Save        :
        style     : "modal-clean-gray"
        callback  : => @doSaveAs file 
      Cancel      :
        style     : "modal-cancel"
        callback  : => @saveAsDialog.hide()

  @saveAsDialog.addSubView wrapper = new KDView
    cssClass : "kddialog-wrapper"

  wrapper.addSubView form = new KDFormView

  form.addSubView labelFileName = new KDLabelView
    title : "Filename:"

  form.addSubView @inputFileName = inputFileName = new KDInputView
    type         : "text"
    label        : labelFileName
    defaultValue : file.name
    placeholder  : "your awesome file name"
    keyup        : (e) => @doSaveAs file if e.which is 13

  form.addSubView labelFinder = new KDLabelView
    title        : "Select a folder:"

  @saveAsDialog.show()
  inputFileName.setFocus()

  @finderController = new NFinderController
    treeItemClass     : NFinderItem
    nodeIdPath        : "path"
    nodeParentIdPath  : "parentPath"
    dragdrop          : yes
    foldersOnly       : yes
    contextMenu       : no

  finder = @finderController.getView()

  form.addSubView finderWrapper = new KDView cssClass : "save-as-dialog file-container",null
  finderWrapper.addSubView finder
  finderWrapper.setHeight 200
  
  @getDelegate().addSubView @saveAsDialog
  
  
CodeMirrorEditor::doSaveAs = (file) ->
  [node] = @finderController.treeController.selectedNodes
  name   = @inputFileName.getValue()

  if name is '' or /^([a-zA-Z]:\\)?[^\x00-\x1F"<>\|:\*\?/]+$/.test(name) is no
    return @notify "Please type valid file name!", "error" 

  return @notify "Please select a folder to save!", "error" unless node

  parent = node.getData()
  file.saveAs @editor.getValue(), name, parent.path, =>
    
  @saveAsDialog.hide()
  
  @utils.wait 500, =>
    {treeController} = KD.getSingleton 'finderController'
    treeController.navigateTo parent.path, =>
      treeController.selectNode treeController.nodes["#{parent.path}/#{name}"]
  
  @emit "CodeMirrorDidSaveAs", parent, name
  