#!/bin/sh
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

# Called with following variables set:
#  - CORE_PATH is absolute path to @apache-mynewt-core
#  - BSP_PATH is absolute path to hw/bsp/bsp_name
#  - BIN_BASENAME is the path to prefix to target binary,
#    .elf appended to name is the ELF file
#  - FEATURES holds the target features string
#  - EXTRA_JTAG_CMD holds extra parameters to pass to jtag software
#  - RESET set if target should be reset when attaching
#  - NO_GDB set if we should not start gdb to debug
#

FILE_NAME=$BIN_BASENAME.elf

. $CORE_PATH/hw/scripts/openocd.sh

CFG="--file $BSP_PATH/openocd.cfg --file $BSP_PATH/debug.cfg"

openocd_debug () {
    if [ -z "$NO_GDB" ]; then
        if [ -z $FILE_NAME ]; then
            echo "Missing filename"
            exit 1
        fi
        if [ ! -f "$FILE_NAME" ]; then
            echo "Cannot find file" $FILE_NAME
            exit 1
        fi

        #
        # Block Ctrl-C from getting passed to openocd.
        #
        set -m
        openocd $CFG -f $OCD_CMD_FILE -c init -c halt >openocd.log 2>&1 &
        openocdpid=$!
        set +m

        GDB_CMD_FILE=.gdb_cmds

        echo "target remote localhost:$PORT" > $GDB_CMD_FILE
        if [ ! -z "$RESET" ]; then
            echo "mon reset halt" >> $GDB_CMD_FILE
        fi

        echo "$EXTRA_GDB_CMDS" >> $GDB_CMD_FILE

        set -m
        $GDB -x $GDB_CMD_FILE $FILE_NAME
        set +m
        rm $GDB_CMD_FILE
        sleep 1
        if [ -d /proc/$openocdpid ] ; then
            kill -9 $openocdpid
        fi
    else
        # No GDB, wait for openocd to exit
        openocd $CFG -f $OCD_CMD_FILE -c init -c halt
        return $?
    fi

    return 0
}

openocd_debug
