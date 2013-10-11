codeMirrorWorkspace = new CodeMirrorWorkspace

appView.addSubView codeMirrorWorkspace

appView.on "FileNeedsToBeOpened", (file) ->
  editorWrapper = codeMirrorWorkspace.getActivePanel().getPaneByName "topLeftPane"
  editorWrapper.openFile file
  
appView.emit "ready"

appView.getAdvancedSettingsMenuView = ->
  return appView.activeEditor.getAdvancedSettingsMenuView()
