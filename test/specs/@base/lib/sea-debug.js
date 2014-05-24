/**
 * Sea.js 2.3.0 | seajs.org/LICENSE.md
 */
(function (global, undefined) {
  var require;
  require = function (path) {
    return require[path];
  };
  if (global.seajs != null) {
    return;
  }

  require['./util-lang'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var isArray, isFunction, isObject, isString, isType;

    isType = function (type) {
      return function (obj) {
        return {}.toString.call(obj) === ("[object " + type + "]");
      };
    };

    isObject = isType("Object");

    isString = isType("String");

    isArray = Array.isArray || isType("Array");

    isFunction = isType("Function");

    exports.isObject = isObject;

    exports.isString = isString;

    exports.isArray = isArray;

    exports.isFunction = isFunction;

    return module.exports;
  })();

  require['./util-dom'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var createScript, getBaseEle, getCurrentScript, getDoc, getHead, getLoaderScript, getScriptAbsoluteSrc, getScripts;

    getDoc = function () {
      return document;
    };

    getHead = function () {
      var doc;
      doc = getDoc();
      return doc.head || doc.getElementsByTagName("head")[0] || doc.documentElement;
    };

    getScripts = function () {
      var doc;
      doc = getDoc();
      return doc.getElementsByTagName('script');
    };

    getBaseEle = function () {
      var head;
      head = getHead();
      return head.getElementsByTagName("base")[0];
    };

    getScriptAbsoluteSrc = function (node) {
      if (node.hasAttribute) {
        return node.src;
      } else {
        return node.getAttribute("src", 4);
      }
    };

    createScript = function () {
      var doc;
      doc = getDoc();
      return doc.createElement('script');
    };

    getCurrentScript = function (currentlyAddingScript, interactiveScript) {
      var script, scripts, _i, _len;
      if (currentlyAddingScript != null) {
        return currentlyAddingScript;
      }
      if ((interactiveScript != null) && interactiveScript.readyState === "interactive") {
        return interactiveScript;
      }
      scripts = getScripts();
      scripts = scripts.reverse();
      for (_i = 0, _len = scripts.length; _i < _len; _i++) {
        script = scripts[_i];
        if (script.readyState === "interactive") {
          interactiveScript = script;
          return interactiveScript;
        }
      }
    };

    getLoaderScript = function () {
      var doc, scripts;
      doc = getDoc();
      scripts = getScripts();
      return doc.getElementById('seajsnode') || scripts[scripts.length - 1];
    };

    exports.getDoc = getDoc;

    exports.getHead = getHead;

    exports.getScripts = getScripts;

    exports.getBaseEle = getBaseEle;

    exports.getScriptAbsoluteSrc = getScriptAbsoluteSrc;

    exports.createScript = createScript;

    exports.getCurrentScript = getCurrentScript;

    exports.getLoaderScript = getLoaderScript;

    return module.exports;
  })();

  require['./util-deps'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var RE, parseDependencies;

    RE = {
      REQUIRE: /"(?:\\"|[^"])*"|'(?:\\'|[^'])*'|\/\*[\S\s]*?\*\/|\/(?:\\\/|[^\/\r\n])+\/(?=[^\/])|\/\/.*|\.\s*require|(?:^|[^$])\brequire\s*\(\s*(["'])(.+?)\1\s*\)/g,
      SLASH: /\\\\/g
    };

    parseDependencies = function (code) {
      var ret;
      ret = [];
      code.replace(RE.SLASH, "").replace(RE.REQUIRE, function (m, m1, m2) {
        if (m2) {
          ret.push(m2);
        }
      });
      return ret;
    };

    exports.RE = RE;

    exports.parseDependencies = parseDependencies;

    return module.exports;
  })();

  require['./util-path'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var RE, addBase, cwd, dirname, getData, getLoaderDir, getLoaderScript, getScriptAbsoluteSrc, id2Uri, isFunction, isString, normalize, parseAlias, parseMap, parsePaths, parseVars, realpath, utilDom, utilLang;

    utilLang = require('./util-lang');

    isString = utilLang.isString;

    isFunction = utilLang.isFunction;

    utilDom = require('./util-dom');

    getLoaderScript = utilDom.getLoaderScript;

    getScriptAbsoluteSrc = utilDom.getScriptAbsoluteSrc;

    getData = function () {
      return seajs.getData();
    };

    RE = {
      DIRNAME: /[^?#]*\//,
      DOT: /\/\.\//g,
      DOUBLE_DOT: /\/[^/]+\/\.\.\//,
      MULTI_SLASH: /([^:/])\/+\//g,
      PATHS: /^([^/:]+)(\/.+)$/,
      VARS: /{([^{]+)}/g,
      ABSOLUTE: /^\/\/.|:\//,
      ROOT_DIR: /^.*?\/\/.*?\//
    };

    dirname = function (path) {
      return path.match(RE.DIRNAME)[0];
    };

    cwd = function () {
      if (location.href != null) {
        return dirname(location.href);
      } else {
        return '';
      }
    };

    getLoaderDir = function () {
      var loaderScript;
      loaderScript = getLoaderScript();
      return dirname(getScriptAbsoluteSrc(loaderScript) || cwd());
    };

    realpath = function (path) {
      path = path.replace(RE.DOT, "/");
      path = path.replace(RE.MULTI_SLASH, "$1/");
      while (path.match(RE.DOUBLE_DOT)) {
        path = path.replace(RE.DOUBLE_DOT, "/");
      }
      return path;
    };

    normalize = function (path) {
      var last, lastC, lastcss, lastjs;
      last = path.length - 1;
      lastC = path.charAt(last);
      lastjs = path.substring(last - 2);
      lastcss = path.substring(last - 3);
      if (lastC === "#") {
        return path.substring(0, last);
      } else if (lastjs === ".js" || lastcss === ".css" || path.indexOf("?") > 0 || lastC === "/") {
        return path;
      } else {
        return path + ".js";
      }
    };

    parseAlias = function (id) {
      var alias, data;
      data = getData();
      alias = data.alias;
      if (alias == null) {
        return id;
      }
      if (isString(alias[id])) {
        return alias[id];
      } else {
        return id;
      }
    };

    parsePaths = function (id) {
      var data, paths;
      data = getData();
      paths = data.paths;
      if (paths == null) {
        return id;
      }
      if (id.match(RE.PATHS && isString(paths[m[1]]))) {
        id = paths[m[1]] + m[2];
      }
      return id;
    };

    parseVars = function (id) {
      var data, vars;
      data = getData();
      vars = data.vars;
      if (vars == null) {
        return id;
      }
      if (id.indexOf("{" > -1)) {
        id = id.replace(RE.VARS, function (m, key) {
          if (isString(vars[key])) {
            return vars[key];
          } else {
            return m;
          }
        });
      }
      return id;
    };

    parseMap = function (uri) {
      var data, map, ret, rule, _i, _len;
      data = getData();
      map = data.map;
      if (map == null) {
        return uri;
      }
      ret = uri;
      for (_i = 0, _len = map.length; _i < _len; _i++) {
        rule = map[_i];
        if (isFunction(rule)) {
          ret = rule(uri) || uri;
        } else {
          ret = uri.replace(rule[0], rule[1]);
        }
        if (ret !== uri) {
          break;
        }
      }
      return ret;
    };

    addBase = function (id, refUri) {
      var data, first, m, ret;
      data = getData();
      first = id.charAt(0);
      if (RE.ABSOLUTE.test(id)) {
        ret = id;
      } else if (first === ".") {
        ret = realpath((refUri != null ? dirname(refUri) : cwd) + id);
      } else if (first === "/") {
        m = data.cwd.match(RE.ROOT_DIR);
        ret = m ? m[0] + id.substring(1) : id;
      } else {
        ret = data.base + id;
      }
      if (ret.indexOf("//") === 0) {
        ret = location.protocol + ret;
      }
      return ret;
    };

    id2Uri = function (id, refUri) {
      var uri;
      if (id == null) {
        return '';
      }
      id = parseAlias(id);
      id = parsePaths(id);
      id = parseVars(id);
      id = normalize(id);
      uri = addBase(id, refUri);
      uri = parseMap(uri);
      return uri;
    };

    exports.RE = RE;

    exports.dirname = dirname;

    exports.cwd = cwd;

    exports.getLoaderDir = getLoaderDir;

    exports.realpath = realpath;

    exports.normalize = normalize;

    exports.parseAlias = parseAlias;

    exports.parsePaths = parsePaths;

    exports.parseVars = parseVars;

    exports.parseMap = parseMap;

    exports.addBase = addBase;

    exports.id2Uri = id2Uri;

    return module.exports;
  })();

  require['./util-events'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var emit, getEvents, _off, _on;

    getEvents = function () {
      var data, events;
      data = seajs.getData();
      events = data.events;
      return events;
    };

    _on = function (name, callback) {
      var events, list;
      events = getEvents();
      list = events[name] || (events[name] = []);
      list.push(callback);
      return seajs;
    };

    _off = function (name, callback) {
      var events, list, _callback_, _i, _len, _ref;
      events = getEvents();
      if (!((name != null) || (callback != null))) {
        events = {};
        return seajs;
      }
      list = events[name];
      if (list != null) {
        if (callback != null) {
          _ref = list.reverse();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            _callback_ = _ref[_i];
            if (_callback_ === callback) {
              list.splice(_i, 1);
            }
          }
        } else {
          delete events[name];
        }
      }
      return seajs;
    };

    emit = function (name, data) {
      var callback, events, list, _i, _len;
      events = getEvents();
      list = events[name];
      if (list != null) {
        list = list.slice();
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          callback = list[_i];
          callback(data);
        }
      }
      return seajs;
    };

    exports.on = _on;

    exports.off = _off;

    exports.emit = emit;

    return module.exports;
  })();

  require['./util-request'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var addOnload, createScript, currentlyAddingScript, emit, getBaseEle, getHead, interactiveScript, isFunction, request, utilDom, utilEvents, utilLang;

    utilLang = require('./util-lang');

    isFunction = utilLang.isFunction;

    utilDom = require('./util-dom');

    getBaseEle = utilDom.getBaseEle;

    getHead = utilDom.getHead;

    createScript = utilDom.createScript;

    utilEvents = require('./util-events');

    emit = utilEvents.emit;

    currentlyAddingScript = null;

    interactiveScript = null;

    request = function (url, callback, charset) {
      var baseElement, cs, node;
      node = createScript();
      if (charset != null) {
        cs = isFunction(charset) ? charset(url) : charset;
        node.charset = cs != null;
      }
      addOnload(node, callback, url);
      node.async = true;
      node.src = url;
      currentlyAddingScript = node;
      baseElement = getBaseEle();
      if (baseElement != null) {
        head.insertBefore(node, baseElement);
      } else {
        head.appendChild(node);
      }
      currentlyAddingScript = null;
    };

    addOnload = function (node, callback, url) {
      var onload, supportOnload;
      supportOnload = "onload" in node;
      onload = function () {
        var head;
        node.onload = node.onerror = node.onreadystatechange = null;
        head = getHead();
        if (typeof debug === "undefined" || debug === null) {
          head.removeChild(node);
        }
        node = null;
        callback();
      };
      if (supportOnload != null) {
        node.onload = onload;
        return node.onerror = function () {
          emit("error", {
            uri: url,
            node: node
          });
          onload();
        };
      } else {
        return node.onreadystatechange = function () {
          if (/loaded|complete/.test(node.readyState)) {
            onload();
          }
        };
      }
    };

    exports.request = request;

    return module.exports;
  })();

  require['./module'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var Module, addBase, emit, getCurrentScript, getData, getDoc, isArray, isFunction, isObject, parseDependencies, request, utilDeps, utilDom, utilEvents, utilLang, utilPath, utilRequest, __bind = function (fn, me) {
      return function () {
        return fn.apply(me, arguments);
      };
    };

    utilLang = require('./util-lang');

    isObject = utilLang.isObject;

    isArray = utilLang.isArray;

    isFunction = utilLang.isFunction;

    utilPath = require('./util-path');

    addBase = utilPath.addBase;

    utilEvents = require('./util-events');

    emit = utilEvents.emit;

    utilRequest = require('./util-request');

    request = utilRequest.request;

    utilDeps = require('./util-deps');

    parseDependencies = utilDeps.parseDependencies;

    utilDom = require('./util-dom');

    getCurrentScript = utilDom.getCurrentScript;

    getDoc = utilDom.getDoc;

    getData = function () {
      return seajs.getData();
    };

    Module = (function () {
      function Module(uri, deps) {
        this.uri = uri;
        this.exec = __bind(this.exec, this);
        this.fetch = __bind(this.fetch, this);
        this.onload = __bind(this.onload, this);
        this.load = __bind(this.load, this);
        this.resolve = __bind(this.resolve, this);
        this.dependencies = deps || [];
        this.exports = null;
        this.status = 0;
        this.callback = null;
        this._waitings = {};
        this._remain = 0;
        return this;
      }

      Module.STATUS = {
        FETCHING: 1,
        SAVED: 2,
        LOADING: 3,
        LOADED: 4,
        EXECUTING: 5,
        EXECUTED: 6
      };

      Module.prototype.resolve = function () {
        var id, ids, mod, uris, _i, _len;
        mod = this;
        ids = mod.dependencies;
        uris = [];
        for (_i = 0, _len = ids.length; _i < _len; _i++) {
          id = ids[_i];
          uris.push(Module.resolve(id, mod.uri));
        }
        return uris;
      };

      Module.prototype.load = function () {
        var STATUS, cachedMods, data, get, m, mod, requestCache, requestUri, uri, uris, _i, _j, _k, _len, _len1, _len2, _results;
        mod = this;
        data = getData();
        cachedMods = data.cachedMods;
        STATUS = Module.STATUS;
        get = Module.get;
        if (mod.status >= STATUS.LOADING) {
          return;
        }
        mod.status = STATUS.LOADING;
        uris = mod.resolve();
        mod._remain = uris.length;
        emit("load", uris);
        for (_i = 0, _len = uris.length; _i < _len; _i++) {
          uri = uris[_i];
          m = get(uri);
          if (m.status < STATUS.LOADED) {
            m._waitings[mod.uri] = (m._waitings[mod.uri] || 0) + 1;
          } else {
            mod._remain--;
          }
        }
        if (mod._remain === 0) {
          mod.onload();
          return;
        }
        requestCache = {};
        if (cachedMods != null) {
          for (_j = 0, _len1 = uris.length; _j < _len1; _j++) {
            uri = uris[_j];
            if (cachedMods[uri] != null) {
              m = cachedMods[uri];
            }
            if (m.status < STATUS.FETCHING) {
              m.fetch(requestCache);
            } else {
              m.load();
            }
          }
        }
        _results = [];
        for (_k = 0, _len2 = requestCache.length; _k < _len2; _k++) {
          requestUri = requestCache[_k];
          if (requestCache.hasOwnProperty(requestUri)) {
            _results.push(requestCache[requestUri]);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      Module.prototype.onload = function () {
        var STATUS, cachedMods, data, m, mod, uri, waitings;
        mod = this;
        STATUS = Module.STATUS;
        data = getData();
        cachedMods = data.cachedMods;
        mod.status = STATUS.LOADED;
        if (mod.callback != null) {
          mod.callback();
        }
        waitings = mod._waitings;
        for (uri in waitings) {
          if (waitings.hasOwnProperty(uri)) {
            m = cachedMods[uri];
            m._remain -= waitings[uri];
            if (m._remain === 0) {
              m.onload();
            }
          }
        }
        delete mod._waitings;
        delete mod._remain;
      };

      Module.prototype.fetch = function (requestCache) {
        var STATUS, callbackList, charset, data, emitData, fetchedList, fetchingList, mod, onRequest, requestUri, sendRequest, uri;
        mod = this;
        STATUS = Module.STATUS;
        data = getData();
        fetchedList = data.fetchedList;
        fetchingList = data.fetchingList;
        callbackList = data.callbackList;
        charset = data.charset;
        uri = mod.uri;
        mod.status = STATUS.FETCHING;
        emitData = {
          uri: uri
        };
        emit("fetch", emitData);
        requestUri = emitData.requestUri || uri;
        if (!requestUri || fetchedList[requestUri]) {
          mod.load();
          return;
        }
        if (fetchingList[requestUri]) {
          callbackList[requestUri].push(mod);
          return;
        }
        fetchingList[requestUri] = true;
        callbackList[requestUri] = [mod];
        onRequest = function () {
          var anonymousMeta, m, mods;
          delete fetchingList[requestUri];
          fetchedList[requestUri] = true;
          if (anonymousMeta) {
            Module.save(uri, anonymousMeta);
            anonymousMeta = null;
          }
          mods = callbackList[requestUri];
          delete callbackList[requestUri];
          while (m = mods.shift()) {
            m.load();
          }
        };
        emitData = {
          uri: uri,
          requestUri: requestUri,
          onRequest: onRequest,
          charset: charset
        };
        emit("request", emitData);
        sendRequest = function () {
          request(emitData.requestUri, emitData.onRequest, emitData.charset);
        };
        if (!emitData.requested) {
          if (requestCache != null) {
            requestCache[emitData.requestUri] = sendRequest;
          } else {
            sendRequest();
          }
        }
      };

      Module.prototype.exec = function () {
        var STATUS, exports, factory, get, mod, require, resolve, uri, use;
        mod = this;
        STATUS = Module.STATUS;
        get = Module.get;
        use = Module.use;
        resolve = Module.resolve;
        if (mod.status >= STATUS.EXECUTING) {
          return mod.exports;
        }
        mod.status = STATUS.EXECUTING;
        uri = mod.uri;
        require = function (id) {
          return get(require.resolve(id).exec());
        };
        require.resolve = function (id) {
          return resolve(id, uri);
        };
        require.async = function (ids, callback) {
          use(ids, callback, uri + "_async_" + cid());
          return require;
        };
        factory = mod.factory;
        exports = isFunction(factory) ? factory(require, mod.exports = {}, mod) : factory;
        if (exports == null) {
          exports = mod.exports;
        }
        delete mod.factory;
        mod.exports = exports;
        mod.status = STATUS.EXECUTED;
        emit("exec", mod);
        return exports;
      };

      Module.config = function (configData) {
        var curr, data, k, key, prev;
        data = getData();
        for (key in configData) {
          curr = configData[key];
          prev = data[key];
          if ((prev != null) && isObject(prev)) {
            for (k in curr) {
              prev[k] = curr[k];
            }
          } else {
            if (isArray(prev)) {
              curr = prev.concat(curr);
            } else if (key === "base") {
              if (curr.slice(-1) !== "/") {
                curr += "/";
              }
              curr = addBase(curr);
            }
            data[key] = curr;
          }
        }
        emit("config", configData);
      };

      Module.resolve = function (id, refUri) {
        var emitData;
        emitData = {
          id: id,
          refUri: refUri
        };
        emit("resolve", emitData);
        return emitData.uri || id2Uri(emitData.id, refUri);
      };

      Module.define = function (id, deps, factory) {
        var argsLen, data, doc, meta, resolve, save, script;
        data = getData();
        resolve = Module.resolve;
        save = Module.save;
        argsLen = arguments.length;
        if (argsLen === 1) {
          factory = id;
          id = undefined;
        } else if (argsLen === 2) {
          factory = deps;
          if (isArray(id)) {
            deps = id;
            id = undefined;
          } else {
            deps = undefined;
          }
        }
        if (!(isArray(deps) && isFunction(factory))) {
          deps = parseDependencies(factory.toString());
        }
        meta = {
          id: id,
          uri: resolve(id),
          deps: deps,
          factory: factory
        };
        doc = getDoc();
        if (!meta.uri && doc.attachEvent) {
          script = getCurrentScript();
          if (script) {
            meta.uri = script.src;
          }
        }
        emit("define", meta);
        if (meta.uri != null) {
          save(meta.uri, meta);
        } else {
          data.anonymousMeta = meta;
        }
      };

      Module.save = function (uri, meta) {
        var STATUS, get, mod;
        STATUS = Module.STATUS;
        get = Module.get;
        mod = get(uri);
        if (mod.status < STATUS.SAVED) {
          mod.id = meta.id || uri;
          mod.dependencies = meta.deps || [];
          mod.factory = meta.factory;
          mod.status = STATUS.SAVED;
          emit("save", mod);
        }
      };

      Module.get = function (uri, deps) {
        var cachedMods, data;
        data = getData();
        cachedMods = data.cachedMods;
        return cachedMods[uri] || (cachedMods[uri] = new Module(uri, deps));
      };

      Module.use = function (ids, callback, uri) {
        var cachedMods, data, get, mod;
        data = getData();
        cachedMods = data.cachedMods;
        get = Module.get;
        mod = get(uri, isArray(ids) ? ids : [ids]);
        mod.callback = function () {
          var exports, uris, _i, _len;
          exports = [];
          uris = mod.resolve();
          for (_i = 0, _len = uris.length; _i < _len; _i++) {
            uri = uris[_i];
            exports.push(cachedMods[uri].exec());
          }
          if (callback != null) {
            callback.apply(global, exports);
          }
          return delete mod.callback;
        };
        mod.load(data);
      };

      Module.define.cmd = {};

      return Module;

    })();

    module.exports = Module;

    return module.exports;
  })();

  require['./data'] = (function () {
    var module, exports;
    exports = {};
    module = {
      exports: exports
    };
    var cwd, data, getLoaderDir, utilPath;

    utilPath = require('./util-path');

    cwd = utilPath.cwd;

    getLoaderDir = utilPath.getLoaderDir;

    data = {};

    data._cid = 0;

    data.cid = function () {
      return data._cid++;
    };

    data.base = getLoaderDir();

    data.dir = getLoaderDir();

    data.cwd = cwd();

    data.charset = "utf-8";

    data.alias = null;

    data.paths = null;

    data.vars = null;

    data.map = null;

    data.debug = null;

    data.map = null;

    data.events = {};

    data.cachedMods = {};

    data.fetchingList = {};

    data.fetchedList = {};

    data.callbackList = {};

    data.anonymousMeta = null;

    module.exports = data;

    return module.exports;
  })();

  var Module, config, data, emit, eventOff, eventOn, get, id2Uri, request, resolve, seajs, use, utilDeps, utilDom, utilEvents, utilLang, utilPath, utilRequest;

  seajs = {};

  utilLang = require('./util-lang');

  utilEvents = require('./util-events');

  eventOn = utilEvents.on;

  eventOff = utilEvents.off;

  emit = utilEvents.emit;

  utilDom = require('./util-dom');

  utilDeps = require('./util-deps');

  utilPath = require('./util-path');

  id2Uri = utilPath.id2Uri;

  utilRequest = require('./util-request');

  request = utilRequest.request;

  Module = require('./module');

  get = Module.get;

  use = Module.use;

  resolve = Module.resolve;

  config = Module.config;

  data = require('./data');

  seajs.cache = data.cachedMods;

  seajs.Module = Module;

  seajs.require = function (id) {
    var mod;
    mod = get(resolve(id));
    if (mod.status < Module.STATUS.EXECUTING) {
      mod.onload();
      mod.exec();
    }
    return mod.exports;
  };

  seajs.resolve = id2Uri;

  seajs.request = request;

  seajs.version = "2.3.0";

  seajs.data = data;

  seajs.getData = function () {
    return seajs.data;
  };

  seajs.config = function (configData) {
    config(configData);
    return seajs;
  };

  seajs.use = function (ids, callback) {
    use(ids, callback, data.cwd + "_use_" + data.cid());
    return seajs;
  };

  seajs.on = function (name, callback) {
    eventOn(name, callback);
    return seajs;
  };

  seajs.off = function (name, callback) {
    eventOff(name, callback);
    return seajs;
  };

  seajs.emit = function (name, data) {
    emit(name, data);
    return seajs;
  };

  global.seajs = seajs;

  global.define = Module.define;

})(this);