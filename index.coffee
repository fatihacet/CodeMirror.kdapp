codeMirrorWorkspace    = new CodeMirrorWorkspace
appView.workspace      = codeMirrorWorkspace

appView.workspace.on "viewAppended", =>
  topLeftPane          = appView.workspace.getActivePanel().getPaneByName "topLeftPane"
  firstCreatedEditor   = topLeftPane.tabView.getActivePane().editor
  appView.activeEditor = firstCreatedEditor

appView.addSubView codeMirrorWorkspace

appView.on "FileNeedsToBeOpened", (file) ->
  appView.activeEditor.getDelegate().openFile file

eventNames = [ "save", "saveAs" , "saveAll"      , "find"   , "findAndReplace",
               "goto", "compile", "compileAndRun", "preview", "quit", "exit"  ]

eventNames.forEach (eventName) =>
  appView.on "#{eventName}MenuItemClicked", =>
    appView.activeEditor.emit "#{eventName}MenuItemClicked"

appView.emit "ready"

appView.getAdvancedSettingsMenuView = ->
  return appView.activeEditor.getAdvancedSettingsMenuView()
