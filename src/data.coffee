utilPath = require './util-path'
{cwd} = utilPath
{getLoaderDir} = utilPath

data = {}

data._cid = 0
data.cid = -> data._cid++

# The loader directory
data.dir = getLoaderDir()
# The current working directory
data.cwd = cwd()
# The charset for requesting files
data.charset = "utf-8"
# The debug flag
data.debug = false
# Config Data
data.config = []

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
