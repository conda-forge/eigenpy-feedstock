#!/bin/sh

mkdir build
cd build

export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

echo $BUILD_NUMPY_INCLUDE_DIRS
echo $TARGET_NUMPY_INCLUDE_DIRS

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  mkdir -p $TARGET_NUMPY_INCLUDE_DIRS
  cp -r $BUILD_NUMPY_INCLUDE_DIRS/numpy $TARGET_NUMPY_INCLUDE_DIRS
fi

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DGENERATE_PYTHON_STUBS=ON \
      -DNUMPY_INCLUDE_DIRS=$TARGET_NUMPY_INCLUDE_DIRS
make
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/eigenpy/eigenpyTargets.cmake
  rm $PREFIX/lib/cmake/eigenpy/eigenpyTargets.cmake.back
fi
