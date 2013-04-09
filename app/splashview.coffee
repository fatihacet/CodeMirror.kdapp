class CodeMirrorSplashView extends JView
  
  constructor: (options = {}, data) ->
    
    options.cssClass = "codemirror-splash-view"
    
    super options, data
    
    @setAsDefault = new KDView
      partial  : "Click here to set CM as your default IDE"
      cssClass : "codemirror-set-as-default" 
      tooltip  : 
        title  : "Coming Soon"
    
  pistachio: ->
    """
      <div class="codemirror-splash">
        <h3>No files are open</h3>
        <p>Alt+N to open an empty file</p>
        <p>Click + to open an empty file</p>
        <p>Drag and drop a file from file tree</p>
        {{> @setAsDefault}}
      </div>
    """