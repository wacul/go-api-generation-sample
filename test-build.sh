#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"
cake -s test -g test/gen build
