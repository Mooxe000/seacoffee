#
# util-events.js
#   - The minimal events support
#
getEvents = ->
  data = seajs.getData()
  {events} = data
  events

# Bind event
# 追加回调方法绑定至事件
_on = (name, callback) ->
  events = getEvents()
  list = events[name] or events[name] = []
  list.push callback
  seajs

# Remove event. If `callback` is undefined, remove all callbacks for the
# event. If `event` and `callback` are both undefined, remove all callbacks
# for all events
# 取消绑定到事件的回调方法
_off = (name, callback) ->
  events = getEvents()
  # Remove *all* events
  # 两个参数均为空，取消所有事件上的回调方法
  unless name? or callback?
    events = {}
    return seajs
  list = events[name]
  if list?
    if callback? # 取消 指定 事件的 指定回调
      for _callback_ in list.reverse()
        list.splice(_i, 1) if _callback_ is callback
    # callback 为空，取消 指定 name 事件的全部回调
    else delete events[name]
  seajs

# Emit event, firing all bound callbacks. Callbacks receive the same
# arguments as `emit` does, apart from the event name
# 触发回调
emit = (name, data) ->
  events = getEvents()
  list = events[name]
  if list?
    # Copy callback lists to prevent modification
    # 复制回调列表，以防止修改
    list = list.slice()
    # Execute event callbacks, use index because it's the faster.
    for callback in list
      callback data
  seajs

exports.on = _on
exports.off = _off
exports.emit = emit