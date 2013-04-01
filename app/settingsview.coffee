class CodeMirrorSettingsView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-settings"
    
    super options, data
    
    @theme = new KDSelectBox
      selectOptions : codeMirrorSettings.themes
      callback      : (value) => 
        @getDelegate().editor.emit "CodeMirrorThemeChanged", value
        
    @syntax = new KDSelectBox
      selectOptions : codeMirrorSettings.modes
      callback      : (value) => 
        @getDelegate().editor.emit "CodeMirrorModeChanged", value
        
  pistachio: ->
    """
      <p>Theme {{> @theme}}</p>
      <p>Syntax {{> @syntax}}</p>
    """