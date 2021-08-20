#!/bin/sh

mkdir build
cd build

#ls $SP_DIR/numpy/core/include
echo $( $PYTHON -c "import numpy; print (numpy.get_include())")

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON
make
make install
