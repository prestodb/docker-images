#!/bin/bash

set -e

function retry() {
  END=$(($(date +%s) + 600))

  while (( $(date +%s) < $END )); do
    set +e
    "$@"
    EXIT_CODE=$?
    set -e

    if [[ ${EXIT_CODE} == 0 ]]; then
      break
    fi
    sleep 5
  done

  return ${EXIT_CODE}
}

function environment_compose() {
  docker compose -f "${DOCKER_CONF_LOCATION}/${ENVIRONMENT}/docker-compose.yml" "$@"
}

function run_in_hadoop_master_container() {
  environment_compose exec hadoop-master "$@"
}

function check_hadoop() {
  run_in_hadoop_master_container hive -e 'select 1;' > /dev/null 2>&1
}

function run_tests() {
  run_in_hadoop_master_container hive -e 'SELECT 1' &&
  run_in_hadoop_master_container hive -e 'CREATE TABLE foo (a INT);' &&
  run_in_hadoop_master_container hive -e 'INSERT INTO foo VALUES (54);' &&
  # SELECT with WHERE to make sure that map-reduce job is scheduled
  run_in_hadoop_master_container hive -e 'SELECT a FROM foo WHERE a > 0;' &&
  true
}

function run_hive_transactional_tests() {
    run_in_hadoop_master_container hive -e "
      CREATE TABLE transactional_table (x int) STORED AS orc TBLPROPERTIES ('transactional'='true');
      INSERT INTO transactional_table VALUES (1), (2), (3), (4);
    " &&
    run_in_hadoop_master_container hive -e 'SELECT x FROM transactional_table WHERE x > 0;' &&
    run_in_hadoop_master_container hive -e 'DELETE FROM transactional_table WHERE x = 2;' &&
    run_in_hadoop_master_container hive -e 'UPDATE transactional_table SET x = 14 WHERE x = 4;' &&
    run_in_hadoop_master_container hive -e 'SELECT x FROM transactional_table WHERE x > 0;' &&
    true
}

function stop_all_containers() {
  local ENVIRONMENT
  for ENVIRONMENT in $(getAvailableEnvironments)
  do
     stop_docker_compose_containers ${ENVIRONMENT}
  done
}

function stop_docker_compose_containers() {
  local ENVIRONMENT=$1
  RUNNING_CONTAINERS=$(environment_compose ps -q)

  if [[ ! -z ${RUNNING_CONTAINERS} ]]; then
    # stop containers started with "up", removing their volumes
    # Some containers (SQL Server) fail to stop on Travis after running the tests. We don't have an easy way to
    # reproduce this locally. Since all the tests complete successfully, we ignore this failure.
    environment_compose down -v || true
  fi

  echo "Docker compose containers stopped: [$ENVIRONMENT]"
}

function cleanup() {
  stop_docker_compose_containers ${ENVIRONMENT}

  # Ensure that the logs processes are terminated.
  # In most cases after the docker containers are stopped, logs processes must be terminated.
  if [[ ! -z ${LOGS_PID} ]]; then
    kill ${LOGS_PID} 2>/dev/null || true
  fi

  # docker logs processes are being terminated as soon as docker container are stopped
  # wait for docker logs termination
  wait 2>/dev/null || true
}

function terminate() {
  trap - INT TERM EXIT
  set +e
  cleanup
  exit 130
}

function getAvailableEnvironments() {
  for i in $(ls -d $DOCKER_CONF_LOCATION/*/); do echo ${i%%/}; done \
     | grep -v files | grep -v common | xargs -n1 basename
}

SCRIPT_DIR=${BASH_SOURCE%/*}
PROJECT_ROOT="${SCRIPT_DIR}/.."
DOCKER_CONF_LOCATION="${PROJECT_ROOT}/etc/compose"

ENVIRONMENT=$1

# Get the list of valid environments
if [[ ! -f "$DOCKER_CONF_LOCATION/$ENVIRONMENT/docker-compose.yml" ]]; then
   echo "Usage: run_on_docker.sh <`getAvailableEnvironments | tr '\n' '|'`>"
   exit 1
fi

shift 1

# check docker and docker compose installation
docker compose version
docker version

stop_all_containers

# catch terminate signals
trap terminate INT TERM EXIT

environment_compose up -d

# start docker logs for the external services
environment_compose logs --no-color -f &

LOGS_PID=$!

# wait until hadoop processes is started
retry check_hadoop

# run tests
set +e
sleep 10
run_tests
if [[ ${ENVIRONMENT} == *"3.1-hive" ]]; then
      run_hive_transactional_tests
fi
EXIT_CODE=$?
set -e

# execution finished successfully
# disable trap, run cleanup manually
trap - INT TERM EXIT
cleanup

exit ${EXIT_CODE}
