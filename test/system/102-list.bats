#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/helpers'

setup() {
  cleanup_all
}

teardown() {
  cleanup_all
}


@test "list: Run 'list' with zero containers and zero images (the list should be empty)" {
  run $TOOLBOX list

  assert_success
  assert_output ""
}

@test "list: Run 'list -c' with zero containers (the list should be empty)" {
  run $TOOLBOX list -c

  assert_success
  assert_output ""
}

@test "list: Run 'list -i' with zero images (the list should be empty)" {
  run $TOOLBOX list -c

  assert_success
  assert_output ""
}

@test "list: Run 'list' with zero toolbox's containers and images, but other image (the list should be empty)" {
  pull_distro_image busybox

  run podman images

  assert_output --partial "$BUSYBOX_IMAGE"

  run $TOOLBOX list

  assert_success
  assert_output ""
}

@test "list: Try to list images and containers (no flag) with 3 containers and 2 images (the list should have 3 images and 2 containers)" {
  # Pull the two images
  pull_default_image
  pull_distro_image fedora 32

  # Create three containers
  create_default_container
  create_container non-default-one
  create_container non-default-two

  # Check images
  run $TOOLBOX list --images

  assert_success
  assert_output --partial "$(get_system_id)-toolbox:$(get_system_version)"
  assert_output --partial "fedora-toolbox:32"

  # Check containers
  run $TOOLBOX list --containers

  assert_success
  assert_output --partial "$(get_system_id)-toolbox-$(get_system_version)"
  assert_output --partial "non-default-one"
  assert_output --partial "non-default-two"

  # Check all together
  run $TOOLBOX list

  assert_success
  assert_output --partial "$(get_system_id)-toolbox:$(get_system_version)"
  assert_output --partial "fedora-toolbox:32"
  assert_output --partial "$(get_system_id)-toolbox-$(get_system_version)"
  assert_output --partial "non-default-one"
  assert_output --partial "non-default-two"
}
