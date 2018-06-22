#!/bin/bash
APPDIR="$(dirname $0)/../"
(
    echo "Before: $(pwd)"
    cd $APPDIR
    echo "After: $(pwd)"
    bin/sms_rest stop
)
