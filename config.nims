#nimble install runs -d:release by default
when defined(release):
    --d:danger    

    #Just defining danger doesn't work, as danger is defined in the general nim.cfg, which is executed before this. These are the -d:danger results:
    --obj_checks:off
    --field_checks:off
    --range_checks:off
    --bound_checks:off
    --overflow_checks:off
    --assertions:off
    --stacktrace:off
    --linetrace:off
    --debugger:off
    --line_dir:off
    --dead_code_elim:on
      
    --excessiveStackTrace:off
    
    --opt:speed

    when defined(nimHasNilChecks):
        --nilchecks:off
