# seajs 源码学习

## ChangeList

### DONE

#### build

1. fork seajs 源码
1. 创建 src_coffee 文件夹
1. 将 src 中源码 搬至 src_coffee
1. 使用 js2coffee 将源码 转为 coffee
1. 对照 转码 与 源码，根据 coffee 编码习惯 修改 转码
1. 移除 seatool 打包依赖，使用 gulp 打包

#### source

1. sea 中 data = seajs.data = {} 分离，sea 中只保留局部变量定义，对外接口移至 Api
1. 新增 Api 文件，将 module 文件中 api (for pub && for dev) 部分移至此文件
1. 移除 config 文件，源码中有三部分内容，调整如下
    * data 属性 下级 属性 移植 sea 中 data 定义后
    * config 主体代码 合并至 module 与 use 同级
    * 接口移至 Api
1. Module 静态 & 动态 方法 分开存放
1. 调整 变量定义 方法定义 位置
1. 将多处 seajs 属性 & 方法 移至 Api

## TODO

1. 使用 module exports require 方式组织 工具包
1. 从 模块 中分离 seajs 初始化 方法
1. 调整构建代码
1. shelljs 方式 写点测试代码
1. 研习 seajs 中 测试案例 测试方式
1. request-css 暂时不做调整

## 打包 顺序

1. sea
1. util-lang
1. util-event
1. util-path
1. util-request
1. util-deps
1. module
1. Api

# 源码分析

## 两个对象

* seajs 外部对象
* module 内部对象，实际处理对象

## 四个外部方法

* seajs.config
* seajs.use
* define
* require

## 七个事件触发插入点

* config
* define
* fetch
* save
* load
* request
* exec

# 为何 没有 require 方法？

require 依赖是 通过 正则分析源码得到的加载项

既然是加载当前模块之前就加载了依赖模块，既不是在执行期再加载的

那么为何要在执行的代码段定义？

不如在模块定义期就把依赖模块写好

那个正则分析看着实在蛋疼

* 这里改成 回调碾平，在执行期才加载 才显得有意义。。（需处理好异步）

## 两个修改阶段

1. 去除 正则分析源码 得到依赖，改为 约定配置的方法得到依赖
1. 得引入 promise。这个工程有点大啊。。。
