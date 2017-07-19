#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

RESULTS=/tmp/prism-results.out
rm $RESULTS

tests=`ls $DIR/test*.yml`
tests=`find $DIR -name test*.yml`

for test in $tests; do
    echo -n "Running `basename $test`: "
    ANSIBLE_ROLES_PATH="$DIR/../.." \
    ANSIBLE_RETRY_FILES_ENABLED=0 \
        ansible-playbook $test >> $RESULTS
    
    rc=$?
    if [ $rc -ne 0 ]; then
        echo 'FAIL'
    else
        echo 'PASS'
    fi
done

echo "Results written to $RESULTS"
