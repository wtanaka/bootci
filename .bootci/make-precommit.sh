#!/bin/sh
# Copyright (C) 2017 Wesley Tanaka
#
# This file is part of github.com/wtanaka/bootci
#
# github.com/wtanaka/bootci is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# github.com/wtanaka/bootci is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with github.com/wtanaka/bootci.  If not, see
# <http://www.gnu.org/licenses/>.

set -e

DIRNAME="`dirname $0`"
PYTHON="${DIRNAME}"/python.sh
# Try to put TARGET in a shorter absolute path so that #! line to the
# python binary does not become too long.  Long lines can lead to "No
# such file or directory" errors.
TARGET="${HOME}"/.pcv

. "${DIRNAME}"/common.sh

"$DIRNAME"/make-virtualenv.sh

"${DIRNAME}/withnopydist.sh" "$PYTHON" -m virtualenv "$TARGET"

(
  . "$TARGET"/bin/activate
  "$TARGET/bin/python" -m pip --version
  retry "$TARGET/bin/python" -m pip install --isolated --upgrade pip
  "$TARGET/bin/python" -m pip --version
  "$TARGET/bin/python" -m pip install --isolated 'requests[security]'
  "$TARGET/bin/python" -m pip install --isolated pre-commit
)
