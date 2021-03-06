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
set -x

PYDISTUTILSCFG="$HOME/.pydistutils.cfg"
PYDISTUTILSCFGBACKUP="$HOME/.pydistutils.cfg.backedup"

restore_config()
{
  if [ -f "$PYDISTUTILSCFGBACKUP" ]; then
     >&2 echo "Restoring $PYDISTUTILSCFG"
     mv "$PYDISTUTILSCFGBACKUP" "$PYDISTUTILSCFG"
  fi
}

install_trap()
{
   for signal in ABRT ALRM BUS FPE HUP \
         ILL INT KILL PIPE QUIT SEGV TERM \
         TSTP TTIN TTOU USR1 USR2 PROF \
         SYS TRAP VTALRM XCPU XFSZ; do
      trap "restore_config; trap $signal; kill -$signal"' $$' $signal
   done
}

clear_config()
{
  if [ -f "$PYDISTUTILSCFG" ]; then
    >&2 echo WARNING -- "$PYDISTUTILSCFG" already exists
    >&2 echo Moving to "$PYDISTUTILSCFGBACKUP" temporarily
    install_trap
    mv "$PYDISTUTILSCFG" "$PYDISTUTILSCFGBACKUP"
  fi
}

cd `dirname $0`

clear_config

>&2 echo "Testing virtualenv works with user=1 in pydistutils"
cat > "$PYDISTUTILSCFG" <<EOF
[install]
user=1
EOF

mkdir subdirtest/
cp -a .bootci subdirtest/.bootci
[ -d subdirtest/.bootci/ ]

# Install pre-commit
.bootci/make-precommit.sh
PRECOMMIT_VENV="${HOME}"/.pcv
command -v "$PRECOMMIT_VENV"/bin/pre-commit
"$PRECOMMIT_VENV"/bin/pre-commit --version 2>&1 | grep '^pre-commit '

if command -v git 2>&1 > /dev/null; then
  # Run pre-commit
  (
    TMPFILE=`mktemp -d -t gitrepoXXXXXXX`
    cd "$TMPFILE"
    git init
    echo 'repos:' > .pre-commit-config.yaml
    echo '- repo: git://github.com/pre-commit/pre-commit-hooks' >> .pre-commit-config.yaml
    echo '  sha: v1.1.1' >> .pre-commit-config.yaml
    echo '  hooks:' >> .pre-commit-config.yaml
    echo '  - id: trailing-whitespace' >> .pre-commit-config.yaml
    . "$PRECOMMIT_VENV"/bin/activate
    "$PRECOMMIT_VENV"/bin/pre-commit run --all-files
    rm -r "$TMPFILE"
  )
fi

# curl
.bootci/make-curl.sh

# gpg
.bootci/make-gpg.sh

# pip
.bootci/make-pip.sh
.bootci/python.sh -m pip

.bootci/make-ansible.sh 1.4
.bootci/venv-ansible1.4/bin/ansible-playbook --version | grep 'ansible-playbook 1.4'
.bootci/ansible-playbook1.4.sh --version | grep 'ansible-playbook 1.4'

.bootci/make-ansible.sh 1.5.4
.bootci/venv-ansible1.5.4/bin/ansible-playbook --version | grep 'ansible-playbook 1.5.4'
.bootci/ansible-playbook1.5.4.sh --version | grep 'ansible-playbook 1.5.4'

subdirtest/.bootci/make-ansible.sh 1.5.4
(
  cd subdirtest
  .bootci/ansible-playbook1.5.4.sh --version | grep 'ansible-playbook 1.5.4'
)

.bootci/make-ansible.sh 1.9.2
.bootci/venv-ansible1.9.2/bin/ansible-playbook --version | grep 'ansible-playbook 1.9.2'
.bootci/ansible-playbook1.9.2.sh --version | grep 'ansible-playbook 1.9.2'

.bootci/make-ansible.sh 2.0.0.2
.bootci/venv-ansible2.0.0.2/bin/ansible-playbook --version | grep 'ansible-playbook 2.0.0.2'
.bootci/ansible-playbook2.0.0.2.sh --version | grep 'ansible-playbook 2.0.0.2'

.bootci/make-ansible.sh 2.1.0.0
.bootci/venv-ansible2.1.0.0/bin/ansible-playbook --version | grep 'ansible-playbook 2.1.0.0'
.bootci/ansible-playbook2.1.0.0.sh --version | grep 'ansible-playbook 2.1.0.0'

# xenial-backports
.bootci/make-ansible.sh 2.1.1.0
.bootci/venv-ansible2.1.1.0/bin/ansible-playbook --version | grep 'ansible-playbook 2.1.1.0'
.bootci/ansible-playbook2.1.1.0.sh --version | grep 'ansible-playbook 2.1.1.0'

# zesty
.bootci/make-ansible.sh 2.2.1.0
.bootci/venv-ansible2.2.1.0/bin/ansible-playbook --version | grep 'ansible-playbook 2.2.1.0'
.bootci/ansible-playbook2.2.1.0.sh --version | grep 'ansible-playbook 2.2.1.0'

# artful
.bootci/make-ansible.sh 2.3.1.0
.bootci/venv-ansible2.3.1.0/bin/ansible-playbook --version | grep 'ansible-playbook 2.3.1.0'
.bootci/ansible-playbook2.3.1.0.sh --version | grep 'ansible-playbook 2.3.1.0'

# Ruby tests
.bootci/make-rvm.sh
command -v rvm || command -v .bootci/rvm/bin/rvm

# gradle
.bootci/make-gradle.sh
# applied https://stackoverflow.com/a/51904549/2034423
# for https://app.shippable.com/
! command -v java || env JAVA_TOOL_OPTIONS="-Dhttps.protocols=TLSv1.2" ./gradlew --version | grep 'Gradle '
