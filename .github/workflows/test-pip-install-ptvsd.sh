# Setup
INSTALL_PATH="$(mktemp -d)"
PYTHON=python2.7
"$PYTHON" install.py "$INSTALL_PATH"
for FOLDER in rez rezplugins
do
    rm -r "${INSTALL_PATH}/lib/${PYTHON}/site-packages/${FOLDER}" \
    && ln -vsf "$(readlink -e src/${FOLDER})" "${INSTALL_PATH}/lib/${PYTHON}/site-packages/"
done
docker run --rm -it \
    --env "INSTALL_PATH=$INSTALL_PATH" \
    --volume "$INSTALL_PATH:$INSTALL_PATH:ro" \
    --volume "$(pwd):$(pwd):ro" \
    centos:7


# entrypoint.sh
curl -sSL https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py | python -  &> /dev/null
export PATH="${INSTALL_PATH}/bin/rez:$PATH"
FAILED=$(mktemp)
INSTALL_OUTPUT=$(mktemp)


# Test, repeat as necessary
rm -rf $HOME/packages \
&& mkdir $HOME/packages \
&& rez bind python &> /dev/null

clear
for PKG in ptvsd requests six future pylint autopep8
do
    rez-pip --python-version 2.7 -i "$PKG" &> "$INSTALL_OUTPUT" \
    && rez env "$PKG" -- python -c "import "$PKG"; print("$PKG".__file__)" || {
        rez env "$PKG" -c 'find $REZ_'${PKG^^}'_ROOT' | cat "$INSTALL_OUTPUT" -
    }
done
