codeMirrorWorkspace = new CodeMirrorWorkspace

appView.addSubView codeMirrorWorkspace

appView.on "FileNeedsToBeOpened", (file) ->
  editorWrapper = codeMirrorWorkspace.getActivePanel().getPaneByName "topLeftPane"
  editorWrapper.openFile file

eventNames = [ "save", "saveAs", "saveAll", "find", "findAndReplace", "goto", "compile", "compileAndRun", "preview", "quit", "exit" ]

eventNames.forEach (eventName) =>
  appView.on "#{eventName}MenuItemClicked", =>
    appView.activeEditor.emit "#{eventName}MenuItemClicked"

appView.emit "ready"

appView.getAdvancedSettingsMenuView = ->
  return appView.activeEditor.getAdvancedSettingsMenuView()
