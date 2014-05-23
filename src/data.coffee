utilPath = require './util-path'
{cwd} = utilPath
{getLoaderDir} = utilPath

data = {}

data._cid = 0
data.cid = -> data._cid++

# The root path to use for id2uri parsing
data.base = getLoaderDir()
# The loader directory
data.dir = getLoaderDir()
# The current working directory
data.cwd = cwd()
# The charset for requesting files
data.charset = "utf-8"

# Config Data
data.alias = null
data.paths = null
data.vars = null
data.map = null
data.debug = null

data.map = null

data.events = {}

data.cachedMods = {}

# 模块 获取中 列表
data.fetchingList = {}
# 已获取 模块 列表
data.fetchedList = {}

# 回调 列表
data.callbackList = {}

data.anonymousMeta = null

module.exports = data
