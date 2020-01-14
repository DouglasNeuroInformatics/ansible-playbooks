export QUARANTINE_PATH=/opt/quarantine
if timeout --signal=KILL 1 stat ${QUARANTINE_PATH}/modules > /dev/null 2>&1; then
  module use ${QUARANTINE_PATH}/modules
fi
