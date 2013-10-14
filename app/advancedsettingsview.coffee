class CodeMirrorAdvancedSettingsView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "editor-advanced-settings-menu"
    
    super options, data
    
    editor = @getDelegate()
    
    @lineNumbers     = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "lineNumbers"       , state
      
    @lineWrapping    = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "useWordWrap"       , state
      
    @styleActiveLine = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "highlightLine"     , state
      
    @highlightSelectionMatches = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "highlightSelectionMatches", state
      
    @scrollPastEnd   = new KDOnOffSwitch
      callback       : (state) -> editor.emit "CodeMirrorSettingsChanged", "scrollPastEnd"     , state
      
    @keyboardHandler = new KDSelectBox
      selectOptions  : __aceSettings.keyboardHandlers
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "keyboardHandler"   , value
      
    @ruler           = new KDMultipleChoice
      labels         : CodeMirrorSettings.rulers
      defaultValue   : [ 80 ]
      multiple       : yes
      callback       : (value) -> # editor.emit "CodeMirrorSettingsChanged", "ruler"           , value
        new KDNotificationView
          type       : "mini"
          title      : "This feature will be implemented soon!"
          duration   : 4000
          
    @layout          = new KDSelectBox
      selectOptions  : CodeMirrorSettings.layouts
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "layout"            , value
    
    @syntax          = new KDSelectBox
      selectOptions  : CodeMirrorSettings.syntaxMap
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "syntax"            , value
      
    @theme           = new KDSelectBox
      selectOptions  : CodeMirrorSettings.themes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "theme"             , value
      
    @fontSize        = new KDSelectBox
      selectOptions  : __aceSettings.fontSizes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "fontSize"          , value
      
    @tabSize         = new KDSelectBox
      selectOptions  : __aceSettings.tabSizes
      callback       : (value) -> editor.emit "CodeMirrorSettingsChanged", "tabSize"           , value
      
  setDefaults: ->
    editorWrapper = @getDelegate()
    inputNames    = [ "lineNumbers" , "fontSize", "tabSize", "styleActiveLine", 
                      "lineWrapping", "syntax"  , "theme"  , "scrollPastEnd"  ]
    
    for inputName in inputNames
      @[inputName].setValue editorWrapper.editor.getOption inputName
      
    @keyboardHandler.setValue editorWrapper.appStorage.getValue "keyboardHandler"
    if editorWrapper.editor.getOption "highlightSelectionMatches"
      @highlightSelectionMatches.setValue yes
  
  viewAppended: ->
    super
    @setDefaults()
  
  pistachio:->
    """
    <div class="ace-settings-view codemirror">
        <p>Line numbers                 {{> @lineNumbers}}</p>
        <p>Use word wrapping            {{> @lineWrapping}}</p>
        <p>Highlight active line        {{> @styleActiveLine}}</p>
        <p>Highlight selection matches  {{> @highlightSelectionMatches}}</p>
        <p>Use scroll past end          {{> @scrollPastEnd}}</p>
        <p>Ruler                        {{> @ruler}}</p>
        <hr>
        <p>Layout                       {{> @layout}}</p>
        <p>Syntax                       {{> @syntax}}</p>
        <p>Theme                        {{> @theme}}</p>
        <p>Key binding                  {{> @keyboardHandler}}</p>
        <p>Font size                    {{> @fontSize}}</p>
        <p>Tab size                     {{> @tabSize}}</p>
      </div>
    """
