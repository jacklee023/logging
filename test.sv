module tb;

// `log_init(Logging::DEBUG);
`log_init();

parameter VERBOSE=15, TEST=25, NOTICE=35, ATTN=45;

initial begin
    $timeformat(-9, 3, " ns");

    log.setup_level("verbose", "v", VERBOSE, Logging::BRIGHT,  Logging::CYAN,  Logging::DEFAULT);
    log.setup_level("test",    "t", TEST,    Logging::DIM,     Logging::GREEN, Logging::DEFAULT);
    log.setup_level("notice",  "n", NOTICE,  Logging::REVERSE, Logging::CYAN,  Logging::DEFAULT);
    log.setup_level("attn",    "a", ATTN,    Logging::BLINK,   Logging::CYAN,  Logging::DEFAULT);

    `define log_verbose(msg) log.display("verbose", msg, $sformatf("%m"), `__FILE__, `__LINE__);
    `define log_test(msg)    log.display("test",    msg, $sformatf("%m"), `__FILE__, `__LINE__);
    `define log_notice(msg)  log.display("notice",  msg, $sformatf("%m"), `__FILE__, `__LINE__);
    `define log_attn(msg)    log.display("attn",    msg, $sformatf("%m"), `__FILE__, `__LINE__);

    log.setup_verbosity(Logging::DEBUG);
    log.setup_section(Logging::LINE, Logging::ENABLE);
    log.setup_filehandle(Logging::INFO, Logging::ENABLE);

    `log_debug("demo string");
    `log_verbose("demo string");
    `log_info("demo string");
    `log_test("demo string");
    `log_warn("demo string");
    `log_notice("demo string");
    `log_error("demo string");
    `log_attn("demo string");
    `log_fatal("demo string");

    foo();
    foo();
    foo();
    bar();

    log.summary();

    log.result(Logging::PASS);
    log.result(Logging::FAIL);
    log.result(Logging::TIMEOUT);
    // log.result(Logging::UNKNOWN);

    `log_teardown;

    $finish();

end

task foo;
    `log_fatal("demo string");
endtask

task bar;
    `log_fatal("demo string");
endtask

endmodule
