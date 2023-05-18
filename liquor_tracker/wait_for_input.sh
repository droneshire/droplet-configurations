#!/bin/bash

wait_for_input() {
    echo "Press any key to continue"
    while [ true ] ; do
        read -t 3 -n 1
        if [ $? = 0 ] ; then
            break
        else
            echo "waiting for the keypress"
        fi
    done
}
