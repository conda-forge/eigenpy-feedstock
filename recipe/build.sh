#!/bin/sh

set -exuo

mkdir build
cd build

export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

export GENERATE_PYTHON_STUBS=1
if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  mkdir -p $TARGET_NUMPY_INCLUDE_DIRS
  cp -r $BUILD_NUMPY_INCLUDE_DIRS/numpy $TARGET_NUMPY_INCLUDE_DIRS
  export GENERATE_PYTHON_STUBS=0
  export Python3_NumPy_INCLUDE_DIR=$TARGET_NUMPY_INCLUDE_DIRS
else
  export Python3_NumPy_INCLUDE_DIR=$BUILD_NUMPY_INCLUDE_DIRS
fi

PYTHON_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"

cmake ${CMAKE_ARGS} .. \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING_SCIPY=OFF \
      -DGENERATE_PYTHON_STUBS=$GENERATE_PYTHON_STUBS \
      -DPython3_NumPy_INCLUDE_DIR=$Python3_NumPy_INCLUDE_DIR \
      -DPython_EXECUTABLE=$PYTHON \
      -DPython_INCLUDE_DIR=$PYTHON_INCLUDE_DIR

cmake --build . --parallel $(($CPU_COUNT/2))
cmake --build . --target install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/eigenpy/eigenpyTargets.cmake
  rm $PREFIX/lib/cmake/eigenpy/eigenpyTargets.cmake.back
fi
