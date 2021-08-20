#!/bin/sh

mkdir build
cd build

#ls $SP_DIR/numpy/core/include
export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

echo $BUILD_NUMPY_INCLUDE_DIRS
echo $TARGET_NUMPY_INCLUDE_DIRS

ln -s BUILD_NUMPY_INCLUDE_DIRS TARGET_NUMPY_INCLUDE_DIRS

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DNUMPY_INCLUDE_DIRS=$TARGET_NUMPY_INCLUDE_DIRS
make
make install
