#!/bin/bash

RETVAL=0
prog="Mojo-RPC Server"
working_directory="/opt/mojo-rpc-server"
application_file="./script/mojo_rpc"
mojo_mode="production"

start() {
        echo -n "Starting $prog: "
        if [ $UID -ne 0 ]; then
                RETVAL=1
                failure
        else
                cd $working_directory
                MOJO_MODE=$mojo_mode hypnotoad $application_file
                RETVAL=$?
        [ $RETVAL -eq 0 ] && success || failure
        fi;
        echo 
        return $RETVAL
}

stop() {
        echo -n "Stopping $prog: "
        if [ $UID -ne 0 ]; then
                RETVAL=1
                failure
        else
                cd $working_directory
                MOJO_MODE=$mojo_mode hypnotoad $application_file --stop
                RETVAL=$?
        [ $RETVAL -eq 0 ] && success || failure
        fi;
        echo
        return $RETVAL
}

restart(){
    stop
    start
}

success() { 
  echo -n "Success"
}

failure() {
  echo -n "Failure"
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
        ;;
  hotdeploy)
    start
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart|hotdeploy}"
    RETVAL=1
esac

exit $RETVAL