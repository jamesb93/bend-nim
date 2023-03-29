#danger
--define:danger
--objChecks:off
--fieldChecks:off
--rangeChecks:off
--boundChecks:off
--overflowChecks:off
--assertions:off
--stacktrace:off
--linetrace:off
--debugger:off
--lineDir:off
--deadCodeElim:on
--nilchecks:off

#release
--gc:refc
--define:release
--excessiveStackTrace:off
--opt:speed

#threading
--threads:on

when defined(nimHasNilChecks):
    --nilchecks:off
