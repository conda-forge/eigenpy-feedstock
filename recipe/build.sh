#!/bin/sh

set -exuo

mkdir build
cd build

BUILD_NUMPY_INCLUDE_DIRS=$($PYTHON -c "import numpy; print (numpy.get_include())")
TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

# CONDA_BUILD_CROSS_COMPILATION is not defined on all platform
# This line prevent set -u to trigger an error
CONDA_BUILD_CROSS_COMPILATION="${CONDA_BUILD_CROSS_COMPILATION:-0}"

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  mkdir -p "$TARGET_NUMPY_INCLUDE_DIRS"
  cp -r "$BUILD_NUMPY_INCLUDE_DIRS/numpy" "$TARGET_NUMPY_INCLUDE_DIRS"
  GENERATE_PYTHON_STUBS=0
  Python_NumPy_INCLUDE_DIR=$TARGET_NUMPY_INCLUDE_DIRS
else
  GENERATE_PYTHON_STUBS=1
  Python_NumPy_INCLUDE_DIR=$BUILD_NUMPY_INCLUDE_DIRS
fi

PYTHON_INCLUDE_DIR="$($PYTHON -c 'import sysconfig; print(sysconfig.get_path("include"))')"

cmake ${CMAKE_ARGS} .. \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING_SCIPY=OFF \
      -DGENERATE_PYTHON_STUBS=$GENERATE_PYTHON_STUBS \
      -DPython_NumPy_INCLUDE_DIR="$Python_NumPy_INCLUDE_DIR" \
      -DPython_EXECUTABLE="$PYTHON" \
      -DPython_INCLUDE_DIR="$PYTHON_INCLUDE_DIR"

cmake --build . --parallel $(($CPU_COUNT/2))
cmake --build . --target install
