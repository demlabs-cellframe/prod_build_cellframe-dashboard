#!/bin/bash

wd=$1

cd $wd
mkdir -p build && cd build

sed -i 's/target_link_libraries(${NODE_TARGET}      ${NODE_LIBRARIES} pthread )/target_link_libraries(${NODE_TARGET}      ${NODE_LIBRARIES} pthread z util expat )/' ../CMakeLists.txt && \
	${CMAKE_PATH}/cmake ../ && make -j$(nproc) || error=$?

exit $error