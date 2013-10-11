CodeMirrorSettings     = cms = 
  rulers               : [ 72, 80, 120 ]
  
  syntaxHandlers       : 
    coffee             : "coffeescript"
    js                 : "javascript"
    json               : "javascript"
    md                 : "markdown"
    html               : "htmlmixed"
    
  autocompleteHandlers : 
    coffee             : "coffeescript"
    js                 : "javascript"
    json               : "javascript"
    html               : "html"
    css                : "css"
    xml                : "xml"
    python             : "python"
  
  themes               : [
    { title            : "3024 Day",           value: "3024-day"                }
    { title            : "3024 Night",         value: "3024-night"              }
    { title            : "Ambiance",           value: "ambiance"                }
    { title            : "Base 16 Dark",       value: "base-16-dark"            }
    { title            : "Base 16 Light",      value: "base-16-light"           }
    { title            : "Blackboard",         value: "blackboard"              }
    { title            : "Cobalt",             value: "cobalt"                  }
    { title            : "Dabbit",             value: "dabbit"                  }
    { title            : "Eclipse",            value: "eclipse"                 }
    { title            : "Elegant",            value: "elegant"                 }
    { title            : "Erlang Dark",        value: "erlang-dark"             }
    { title            : "Github",             value: "github"                  }
    { title            : "Lesser Dark",        value: "lesser-dark"             }
    { title            : "Midnight",           value: "midnight"                }
    { title            : "Monokai",            value: "monokai"                 }
    { title            : "Neat",               value: "neat"                    }
    { title            : "Night",              value: "night"                   }
    { title            : "Paraiso Dark",       value: "paraiso-dark"            }
    { title            : "Paraiso Light",      value: "paraiso-light"           }
    { title            : "Ruby Blue",          value: "rubyblue"                }
    { title            : "Solarized",          value: "solarized"               }
    { title            : "The Matrix",         value: "the-matrix"              }
    { title            : "Tomorrow Night 80s", value: "tomorrow-night-eighties" }
    { title            : "Twilight",           value: "twilight"                }
    { title            : "Vibrant Ink",        value: "vibrant-ink"             }
    { title            : "XQ Dark",            value: "xq-dark"                 }
    { title            : "XQ Light",           value: "xq-light"                }
  ]

# cms is shorthand for CodeMirrorSettings
CodeMirrorSettings.syntaxMap = [
    { title            : "CoffeeScript",      value: cms.syntaxHandlers.coffee  }
    { title            : "JavaScript",        value: cms.syntaxHandlers.js      }
    { title            : "Markdown",          value: cms.syntaxHandlers.md      }
    { title            : "JSON",              value: cms.syntaxHandlers.json    }
    { title            : "HTML",              value: cms.syntaxHandlers.html    }
  ]