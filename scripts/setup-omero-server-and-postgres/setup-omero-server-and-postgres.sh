#!/bin/bash

# Create directories in your home folder
mkdir -p ~/omero/{server,ice,venv,data}

cat << EOF > ~/omero/settings.env
export OMERO_DB_USER=db_user
export OMERO_DB_PASS=db_password
export OMERO_DB_NAME=omero_database
export OMERO_ROOT_PASS=omero_root_password
export OMERO_DATA_DIR=$HOME/omero/data
export OMERODIR=$HOME/omero/server/OMERO.server
export ICE_HOME=$HOME/omero/ice/Ice-3.6.5
export VENV_SERVER=$HOME/omero/venv
export PATH=$ICE_HOME/bin:$VENV_SERVER/bin:$PATH
export LD_LIBRARY_PATH=$ICE_HOME/lib64:$LD_LIBRARY_PATH
export SLICEPATH=$ICE_HOME/slice
export PGPASSWORD="$OMERO_DB_PASS"
export PGPORT=5433
export PATH=~/postgresql/bin:$PATH
export PGDATA=~/postgresql/data
EOF

source ~/omero/settings.env

# Download Ice binaries
cd ~/omero/ice
wget https://github.com/glencoesoftware/zeroc-ice-ubuntu2204-x86_64/releases/download/20221004/Ice-3.6.5-ubuntu2204-x86_64.tar.gz
tar xf Ice-3.6.5-ubuntu2204-x86_64.tar.gz

# Create virtual environment
python3 -m venv $VENV_SERVER
source $VENV_SERVER/bin/activate
pip install --upgrade pip

pip install https://github.com/glencoesoftware/zeroc-ice-py-ubuntu2204-x86_64/releases/download/20221004/zeroc_ice-3.6.5-cp310-cp310-linux_x86_64.whl

pip install omero-server


# Install OMERO.server locally
cd ~/omero/server
wget https://downloads.openmicroscopy.org/omero/5.6/server-ice36.zip -O OMERO.server-ice36.zip
unzip OMERO.server-ice36.zip
ln -s OMERO.server-*/ OMERO.server


# Setup PostgreSQL Database locally
cd ~/downloads
wget https://github.com/theseus-rs/postgresql-binaries/releases/download/VERSION/postgresql-17.5-x86_64-unknown-linux-gnu.tar.gz

mkdir -p ~/postgresql
tar -xzf postgresql-17.5-*.tar.gz -C ~/postgresql --strip-components=1
mkdir -p ~/postgresql/data
~/postgresql/bin/initdb -D ~/postgresql/data
sed -i 's/#port = 5432/port = 5433/' ~/postgresql/data/postgresql.conf
echo listen_addresses = \'localhost\' >> ~/postgresql/data/postgresql.conf
~/postgresql/bin/pg_ctl -D ~/postgresql/data -l ~/postgresql/logfile start
~/postgresql/bin/pg_ctl -D ~/postgresql/data status

# Use psql and Create a User/DB
~/postgresql/bin/psql -p 5433 postgres
CREATE USER $OMERO_DB_USER WITH PASSWORD 'db_password';
CREATE DATABASE $OMERO_DB_NAME OWNER $OMERO_DB_USER ENCODING 'UTF8';

# shows users
\du

# shows databases
\l

# Configure OMERO.server
cd $OMERODIR
omero config set omero.data.dir "$OMERO_DATA_DIR"
omero config set omero.db.name "$OMERO_DB_NAME"
omero config set omero.db.user "$OMERO_DB_USER"
omero config set omero.db.pass "$OMERO_DB_PASS"
omero config set omero.db.host localhost
omero config set omero.db.port "$PGPORT"

omero db script -f db.sql --password "$OMERO_ROOT_PASS"
psql -h localhost -U "$OMERO_DB_USER" "$OMERO_DB_NAME" < db.sql

omero certificates

echo Omero-server setup is done.

# omero admin start
# omero admin diagnostics
# omero admin stop
