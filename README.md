# logging for systemverilog

[TOC]

参考python logging模块和UVM的`uvm_info`, 实现了分级打印log，log着色，控制log输出verbosity等级功能

## feature

1. 打印log当前时间点、所在文件、行号和所在模块
2. 分级打印log，默认支持5个等级，`DEBUG(10) < INFO(20) < WARN(30) < ERROR(40) < FATAL(50)`
3. 支持自定义等级
4. 支持静态、动态配置verbosity等级
5. 支持配置不同等级、不同字段的样式
6. 提供task打印汇总信息
7. 提供task打印足够明确的pass/fail字符

## function/task

### 公有方法
#### funtion new();
构造函数, 用作初始化Logging类
参数：
+ level: 类初始化时修改verbosity, 可选，默认值为info级

提供对应的宏，方便使用

典型用法：
```systemverilog
Logging log=new(lvl);
// 或
`log_init(Logging::DEBUG);
`log_init();
```

#### task display();
用作打印log信息，包括分级打印、着色和统计功能，并可以接受命令行参数(`+l`或`+log`)控制verbosity

参数:
+ name: log级别的名称，默认支持debug，info，warn，error，fatal
+ msg: 需要打印的信息，可以使用函数`$sformatf()`
+ hier: log信息所在层级
+ file: log信息所在文件
+ line: log信息所在行号

提供对应的宏，方便使用

典型用法：
```systemverilog
log.display("info",   msg, $sformatf("%m"), `__FILE__, `__LINE__);
```

#### task setup_style();
用作设置指定级别(level)、字段(section)、状态(status)的样式

参数：
+ key: level_t, section_t, status_t类型, 指定要设置的目标
+ attr: attr_t类型, 指定属性
+ fg:  color_t类型，前景色
+ bg:  color_t类型，后景色

典型用法：
```systemverilog
log.setup_style(Logging:TIME, Logging:DIM, Logging:WHITE, Logging:DEFAULT);
```

#### task setup_verbosity();
用作设置verbosity

参数：
+ level: level_t类型, 指定要级别

典型用法：
```systemverilog
log.setup_verbosity(Logging::DEBUG);
```

#### task setup_section();
用于设置指定字段是否显示

参数：
+ sec: section_t类型, 指定字段
+ flag: flag_t类型, 显示或不显示

典型用法：
```systemverilog
log.setup_section(Logging::LINE, Logging::ENABLE);
```

#### task setup_counter();
用于设置指定级别的计数器值

参数：
+ level: level_t类型, 指定级别
+ value: integer类型，计数值

典型用法：
```systemverilog
log.setup_counter(Logging::INFO,0);
```

#### task setup_filehandle();
用于设置指定级别是否输出到文件

参数：
+ level: level_t类型, 指定级别
+ flag: flag_t类型, 输出或不输出
+ logformat: string类型, log文件格式，默认为`./log_${NAME}.log`

典型用法：
```systemverilog
log.setup_filehandle(Logging::INFO, Logging::ENABLE);
```

#### task setup_level();
用于设置/新建级别相关配置

参数：
+ name: string类型, 级别名称
+ short: string类型, 级别名称(缩写)
+ level: level_t类型, 指定级别
+ attr: attr_t类型, 指定属性
+ fg:  color_t类型，前景色
+ bg:  color_t类型，后景色

典型用法：
```systemverilog
log.setup_level("verbose", "v", VERBOSE, Logging::BRIGHT,  Logging::CYAN,  Logging::DEFAULT);
```

#### task summary();
用于在仿真结束时打印统计信息

无参数

典型用法：
```systemverilog
log.setup_level("verbose", "v", VERBOSE, Logging::BRIGHT,  Logging::CYAN,  Logging::DEFAULT);
```

#### task result();
用于在仿真结束时打印足够明确的pass/fail标志

参数:
+ status: status_t类型，仿真状态，目前支持pass/fail/timeout，其他输入值一律打印为unknown

典型用法：
```systemverilog
log.result(Logging::PASS);
```

#### task teardown();
用于在仿真结束时清理文件句柄，清零计数器等
如果使用输出到文件功能，可以不调用它
提供一个对应的宏，方便使用, 注意该宏是无参数的

典型用法：
```systemverilog
log.teardown();
// 或
`log_teardown;
```

### 私有方法
#### protected task _write();
用于最终输出格式化后字符

参数：
+ msgs: string数组，待输出字符串列表
+ sytle: style_t类型，指定输出样式
+ fh: integer类型，输出文件句柄

#### protected task _colorize();
用于对指定字符串根据其所在级别或所在字段进行着色

参数：
+ name：string类型，所在级别
+ sec：section_t类型， 所在字段
+ line: string类型，待输出字符串

## define

### `log_init()
等价于 `Logging log=new(lvl);`

### `log_debug()
等价于
```systemverilog
log.display("debug",   msg, $sformatf("%m"), `__FILE__, `__LINE__);
```

### `log_info() `log_warn() `log_error() `log_fatal()
同上

### `log_teardown
等价于`log.teardown();`

## usage
1. 将logging.sv添加到filelist中

2. 在需要使用logging之前，加入
```systemverilog
`log_init();
```

3. 根据需要选择不同级别的log宏
```systemverilog
`log_debug();
`log_info();
`log_warn();
`log_error();
`log_fatal();
```

4. 在仿真结束前，根据需要调用以下task
```systemverilog
log.summary();
log.result(Logging::PASS);
log.result(Logging::FAIL);
```

5. 如果使用`set_filehandle`打开了输出到文件功能，在仿真结束之前最好调用一次teardown
```systemverilog
`log_teardown();
```

## demo

### log.display()

![display](imgs\display.png)

### log.summary()

![summary](imgs\summary.png)


### log.result()

![result](imgs\result.png)


## reference
- https://discuss.systemverilog.io/t/file-and-line/12
- https://asic-design-verification.blogspot.com/2008/08/learn-to-display-color-messages-using.html
- https://en.wikipedia.org/wiki/ANSI_escape_code
