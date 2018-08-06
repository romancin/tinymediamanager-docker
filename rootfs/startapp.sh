#!/bin/sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_tmm" EXIT

log() {
    echo "[tmmsupervisor] $*"
}

getpid_tmm() {
    PID=UNSET
    if [ -f /config/tmm.pid ]; then
        PID="$(cat /config/tmm.pid)"
        # Make sure the saved PID is still running and is associated to
        # TinyMediaManager.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "tmm.jar"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "tmm.jar" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_tmm_running() {
    [ "$(getpid_tmm)" != "UNSET" ]
}

start_tmm() {
        /opt/jre/bin/java -Dsilent=noupdate -jar /config/getdown.jar /config > /config/logs/output.log 2>&1 &
}

kill_tmm() {
    PID="$(getpid_tmm)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating TinyMediaManager..."
        kill $PID
        wait $PID
    fi
}

if ! is_tmm_running; then
    log "TinyMediaManager not started yet.  Proceeding..."
    start_tmm
fi

TMM_NOT_RUNNING=0
while [ "$TMM_NOT_RUNNING" -lt 60 ]
do
    if is_tmm_running; then
        TMM_NOT_RUNNING=0
    else
        TMM_NOT_RUNNING="$(expr $TMM_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "TinyMediaManager no longer running.  Exiting..."
