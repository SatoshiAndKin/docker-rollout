#!/usr/bin/env bats

setup() {
  ROLLOUT="$BATS_TEST_DIRNAME/../docker-rollout"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/docker" <<'SH'
#!/bin/sh
# Compose can reject bare usage while its version command succeeds.
[ "$MOCK_COMPOSE" = "v2" ] && [ "$1" = "compose" ] && [ "$2" = "version" ]
SH
  cat > "$BATS_TEST_TMPDIR/bin/docker-compose" <<'SH'
#!/bin/sh
[ "$MOCK_COMPOSE" = "v1" ] && [ "$1" = "version" ]
SH
  chmod +x "$BATS_TEST_TMPDIR/bin/docker" "$BATS_TEST_TMPDIR/bin/docker-compose"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "detects Compose v2 when bare usage returns an error" {
  export MOCK_COMPOSE=v2
  run "$ROLLOUT" rollout --version
  [ "$status" -eq 0 ]
  [[ "$output" == docker-rollout\ version* ]]
}

@test "detects standalone Compose when bare usage returns an error" {
  export MOCK_COMPOSE=v1
  run "$ROLLOUT" rollout --version
  [ "$status" -eq 0 ]
  [[ "$output" == docker-rollout\ version* ]]
}
