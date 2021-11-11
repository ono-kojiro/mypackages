path_add() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}

add_ld_library_path() {
    if [ -d "$1" ] && [[ ":$LD_LIBRARY_PATH:" != *":$1:"* ]]; then
        LD_LIBRARY_PATH="$1:$LD_LIBRARY_PATH"
    fi
}

ROOT=/opt/cmake-3.19.8

path_add $ROOT/usr/bin
export PATH

add_ld_library_path $ROOT/usr/lib
export LD_LIBRARY_PATH


