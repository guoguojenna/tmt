#!/bin/bash
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup
        rlRun "pushd data"
        rlRun "set -o pipefail"
        rlRun "run=/var/tmp/tmt/run-upgrade"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun -s "tmt run --scratch -vvvdddi $run --rm --before finish plan -n /plan/path" 0 "Run the upgrade test"
        # 1 test before + 3 upgrade tasks + 1 test after
        rlAssertGrep "5 tests passed" $rlRun_LOG
        # Check that the IN_PLACE_UPGRADE variable was set
        rlAssertGrep "IN_PLACE_UPGRADE=old" "$run/plan/path/execute/data/old/test/output.txt"
        rlAssertGrep "IN_PLACE_UPGRADE=new" "$run/plan/path/execute/data/new/test/output.txt"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "tmt run -l finish" 0 "Stop the guest and remove the workdir"
        rlRun "popd"
    rlPhaseEnd
rlJournalEnd