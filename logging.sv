class Logging;

    typedef enum integer {RESET=0, BRIGHT=1, DIM=2, ITALIC=3, UNDERLINE=4, BLINK=5, REVERSE=7, HIDDEN=8, STRIKE=9} attr_t;
    typedef enum integer {BLACK=0, RED=1, GREEN=2, YELLOW=3, BLUE=4, PURPLE=5, CYAN=6, WHITE=7, DEFAULT=9} color_t;
    typedef enum integer {DEBUG=10, INFO=20, WARN=30, ERROR=40, FATAL=50} level_t;
    typedef enum integer {TIME=90, FILE=91, LINE=92, HIER=93, NAME=94, MSG=95, SUMMARY=96} section_t;
    typedef enum logic   {DISABLE=0, ENABLE=1} flag_t;
    typedef enum integer {PASS=97, FAIL=98, TIMEOUT=99, UNKNOWN=100} status_t;

    typedef struct{
        attr_t attr;
        color_t fg;
        color_t bg;
    } style_t;

    protected style_t styles[integer]; // level_t, section_t, status_t
    protected integer counters[level_t];
    protected level_t levels[string];
    protected string  names[level_t];
    protected integer filehandles[level_t];
    protected string lognames[level_t];
    protected level_t verbosity = INFO;

    protected flag_t sections[section_t] = '{
        TIME : ENABLE,
        FILE : ENABLE,
        LINE : ENABLE,
        HIER : ENABLE,
        NAME : ENABLE,
        MSG  : ENABLE
    };

    string banners[status_t][6];

    function new(input level_t level=INFO);
        this.verbosity = level;

        banners[PASS][0]    = "        ██████╗  █████╗ ███████╗███████╗\n";
        banners[PASS][1]    = "        ██╔══██╗██╔══██╗██╔════╝██╔════╝\n";
        banners[PASS][2]    = "        ██████╔╝███████║███████╗███████╗\n";
        banners[PASS][3]    = "        ██╔═══╝ ██╔══██║╚════██║╚════██║\n";
        banners[PASS][4]    = "        ██║     ██║  ██║███████║███████║\n";
        banners[PASS][5]    = "        ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝\n";

        banners[FAIL][0]    = "        ███████╗ █████╗ ██╗██╗     \n";
        banners[FAIL][1]    = "        ██╔════╝██╔══██╗██║██║     \n";
        banners[FAIL][2]    = "        █████╗  ███████║██║██║     \n";
        banners[FAIL][3]    = "        ██╔══╝  ██╔══██║██║██║     \n";
        banners[FAIL][4]    = "        ██║     ██║  ██║██║███████╗\n";
        banners[FAIL][5]    = "        ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝\n";

        banners[TIMEOUT][0] = "        ████████╗██╗███╗   ███╗███████╗ ██████╗ ██╗   ██╗████████╗\n";
        banners[TIMEOUT][1] = "        ╚══██╔══╝██║████╗ ████║██╔════╝██╔═══██╗██║   ██║╚══██╔══╝\n";
        banners[TIMEOUT][2] = "           ██║   ██║██╔████╔██║█████╗  ██║   ██║██║   ██║   ██║   \n";
        banners[TIMEOUT][3] = "           ██║   ██║██║╚██╔╝██║██╔══╝  ██║   ██║██║   ██║   ██║   \n";
        banners[TIMEOUT][4] = "           ██║   ██║██║ ╚═╝ ██║███████╗╚██████╔╝╚██████╔╝   ██║   \n";
        banners[TIMEOUT][5] = "           ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝ ╚═════╝  ╚═════╝    ╚═╝   \n";

        banners[UNKNOWN][0] = "        ██╗   ██╗███╗   ██╗██╗  ██╗███╗   ██╗ ██████╗ ██╗    ██╗███╗   ██╗\n";
        banners[UNKNOWN][1] = "        ██║   ██║████╗  ██║██║ ██╔╝████╗  ██║██╔═══██╗██║    ██║████╗  ██║\n";
        banners[UNKNOWN][2] = "        ██║   ██║██╔██╗ ██║█████╔╝ ██╔██╗ ██║██║   ██║██║ █╗ ██║██╔██╗ ██║\n";
        banners[UNKNOWN][3] = "        ██║   ██║██║╚██╗██║██╔═██╗ ██║╚██╗██║██║   ██║██║███╗██║██║╚██╗██║\n";
        banners[UNKNOWN][4] = "        ╚██████╔╝██║ ╚████║██║  ██╗██║ ╚████║╚██████╔╝╚███╔███╔╝██║ ╚████║\n";
        banners[UNKNOWN][5] = "         ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝\n";

        this.setup_level("debug",   "d", DEBUG,   UNDERLINE, BLUE,   DEFAULT);
        this.setup_level("info",    "i", INFO,    BRIGHT,    GREEN,  DEFAULT);
        this.setup_level("warn",    "w", WARN,    BRIGHT,    YELLOW, DEFAULT);
        this.setup_level("error",   "e", ERROR,   BRIGHT,    RED,    DEFAULT);
        this.setup_level("fatal",   "f", FATAL,   BRIGHT,    PURPLE, DEFAULT);

        this.setup_style(TIME,    DIM,    WHITE,  DEFAULT);
        this.setup_style(FILE,    BRIGHT, YELLOW, DEFAULT);
        this.setup_style(LINE,    BRIGHT, RED,    DEFAULT);
        this.setup_style(HIER,    BRIGHT, WHITE,  DEFAULT);
        this.setup_style(SUMMARY, BRIGHT, BLUE,   DEFAULT);

        this.setup_style(PASS,    BRIGHT, GREEN,  DEFAULT);
        this.setup_style(FAIL,    BRIGHT, RED,    DEFAULT);
        this.setup_style(TIMEOUT, BRIGHT, YELLOW, DEFAULT);
        this.setup_style(UNKNOWN, BLINK,  CYAN,   DEFAULT);

    endfunction

    task display(
        input string name,
        input string msg,
        input string hier="",
        input string file="",
        input integer line=-1
    );
        string arg;
        level_t level = levels[name];

        if ($value$plusargs("l=%s", arg)  ||
            $value$plusargs("log=%s", arg)) begin
            verbosity = levels[arg];
        end

        if (level >= verbosity) begin
            this._colorize(name, TIME, $sformatf("[@%12t] ", $realtime));
            this._colorize(name, FILE, $sformatf("%s ", file));
            this._colorize(name, LINE, $sformatf("(%-d) ", line));
            this._colorize(name, HIER, $sformatf("-> %s ", hier));
            this._colorize(name, NAME, $sformatf("[%s] ", name));
            this._colorize(name, MSG,  $sformatf("%s\n", msg));

            this.counters[level] += 1;
        end
    endtask

    task setup_style(input integer key,  // level_t, section_t, status_t
                     input attr_t attr=BRIGHT,
                     input color_t fg=DEFAULT,
                     input color_t bg=DEFAULT
        );
        this.styles[key] = '{attr, fg, bg};
    endtask

    task setup_verbosity(input level_t level);
        this.verbosity = level;
    endtask

    task setup_section(input section_t sec, input flag_t flag);
        this.sections[sec] = flag;
    endtask

    task setup_counter(input level_t level, input integer value=0);
        this.counters[level] = value;
    endtask

    task setup_filehandle(input level_t level,
                          input flag_t flag=DISABLE,
                          input string logformat="./log_%s.log");
        if (flag == ENABLE) begin
            this.lognames[level] = $sformatf(logformat, this.names[level]);
            this.filehandles[level] = $fopen(this.lognames[level], "w");
        end else begin
            $fclose(this.filehandles[level]);
            this.lognames[level] = "";
            this.filehandles[level] = DISABLE;
        end
    endtask

    task setup_level(input string name,
                     input string short,
                     input level_t level,
                     input attr_t attr=BRIGHT,
                     input color_t fg=DEFAULT,
                     input color_t bg=DEFAULT
    );
        this.names[level]  = name;
        this.levels[name]  = level;
        this.levels[short] = level;
        this.setup_filehandle(level, DISABLE);
        this.setup_counter(level, 0);
        this.setup_style(level, attr, fg, bg);
    endtask

    task summary();
        string msgq[$];
        integer fh = this.filehandles[INFO];
        style_t style = this.styles[SUMMARY];

        msgq.push_back($sformatf("logging counter:\n"));

        foreach (this.counters[level]) begin
            msgq.push_back($sformatf("  %-8s : %-d\n", this.names[level], this.counters[level]));
        end

        msgq.push_back($sformatf("logging verbosity: %s\n", this.names[this.verbosity]));
        msgq.push_back($sformatf("logging lognames:\n"));

        foreach (this.lognames[level]) begin
            msgq.push_back($sformatf("  %-8s : %s\n", this.names[level], this.lognames[level]));
        end

        this._write(msgq, style, fh);

    endtask

    protected task _write(input string msgs[], input style_t style, input integer fh=DISABLE);
        $write("%c[%c;3%c;4%cm", 27, style.attr+48, style.fg+48, style.bg+48);
        foreach (msgs[i]) begin
            $write(msgs[i]);
        end
        $write("%c[0m", 27);
        if (fh != DISABLE) begin
            $fwrite(fh, "%c[%c;3%c;4%cm", 27, style.attr+48, style.fg+48, style.bg+48);
            foreach (msgs[i]) begin
                $fwrite(fh, msgs[i]);
            end
            $fwrite(fh, "%c[0m", 27);
        end
    endtask

    protected task _colorize(input string name, input section_t sec, input string line);
        integer fh;
        level_t level;
        style_t style;
        if (this.sections[sec]) begin
            level = this.levels[name];
            fh = this.filehandles[level];
            if (sec == NAME || sec == MSG) begin
                style = this.styles[level];
            end else begin
                style = this.styles[sec];
            end
            this._write('{line}, style, fh);
        end
    endtask

    task result(input status_t status=UNKNOWN);
        if (!this.banners.exists(status)) begin
            status = UNKNOWN;
        end
        this._write(this.banners[status], this.styles[status]);
    endtask

    task teardown();
        foreach (this.filehandles[level]) begin
            this.setup_filehandle(level, DISABLE);
        end
        foreach (this.counters[level]) begin
            this.setup_counter(level, DISABLE);
        end
    endtask

endclass

`define log_init(lvl)    Logging log=new(lvl);
`define log_debug(msg)   log.display("debug",   msg, $sformatf("%m"), `__FILE__, `__LINE__);
`define log_info(msg)    log.display("info",    msg, $sformatf("%m"), `__FILE__, `__LINE__);
`define log_warn(msg)    log.display("warn",    msg, $sformatf("%m"), `__FILE__, `__LINE__);
`define log_error(msg)   log.display("error",   msg, $sformatf("%m"), `__FILE__, `__LINE__);
`define log_fatal(msg)   log.display("fatal",   msg, $sformatf("%m"), `__FILE__, `__LINE__);
`define log_teardown     log.teardown();

