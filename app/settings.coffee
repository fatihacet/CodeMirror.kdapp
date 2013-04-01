codeMirrorSettings =
  themes: [
    { title: "Ambiance",       value: "ambiance" }
    { title: "Blackboard",     value: "blackboard" }
    { title: "Cobalt",         value: "cobalt" }
    { title: "Eclipse",        value: "eclipse" }
    { title: "Elegant",        value: "elegant" }
    { title: "Erlang Dark",    value: "erlang-dark" }
    { title: "Lesser Dark",    value: "lesser-dark" }
    { title: "Monokai",        value: "monokai" }
    { title: "Neat",           value: "neat" }
    { title: "Night",          value: "night" }
    { title: "Ruby Blue",      value: "rubyblue" }
    { title: "Solarized",      value: "solarized" }
    { title: "Twilight",       value: "twilight" }
    { title: "Vibrant Ink",    value: "vibrant-ink" }
    { title: "Xq Dark",        value: "xq-dark" }
    { title: "Xq Light",       value: "xq-light" }
  ]
  
  modes: [
    { title: "JavaScript",     value: "javascript" }
    { title: "CSS",            value: "css" }
    { title: "CoffeeScript",   value: "coffeescript" }
    { title: "PHP",            value: "php" }
  ]
  
  sampleCode: """
    function getCompletions(token, context) {
      var found = [], start = token.string;
      function maybeAdd(str) {
        if (str.indexOf(start) == 0) found.push(str);
      }
      function gatherCompletions(obj) {
        if (typeof obj == "string") forEach(stringProps, maybeAdd);
        else if (obj instanceof Array) forEach(arrayProps, maybeAdd);
        else if (obj instanceof Function) forEach(funcProps, maybeAdd);
        for (var name in obj) maybeAdd(name);
      }
    
      if (context) {
        // If this is a property, see if it belongs to some object we can
        // find in the current environment.
        var obj = context.pop(), base;
        if (obj.className == "js-variable")
          base = window[obj.string];
        else if (obj.className == "js-string")
          base = "";
        else if (obj.className == "js-atom")
          base = 1;
        while (base != null && context.length)
          base = base[context.pop().string];
        if (base != null) gatherCompletions(base);
      }
      else {
        // If not, just look in the window object and any local scope
        // (reading into JS mode internals to get at the local variables)
        for (var v = token.state.localVars; v; v = v.next) maybeAdd(v.name);
        gatherCompletions(window);
        forEach(keywords, maybeAdd);
      }
      return found;
    }
  """