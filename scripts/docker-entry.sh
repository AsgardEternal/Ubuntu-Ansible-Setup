#!/bin/sh

mkdir -p "${HOME}/.ssh"
touch "${HOME}/.ssh/authorized_keys" >/dev/null 2>&1 || true
chmod 0600 "${HOME}/.ssh/authorized_keys"
