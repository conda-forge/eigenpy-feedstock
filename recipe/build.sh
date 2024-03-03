#!/bin/sh

mkdir build
cd build

export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

echo $BUILD_NUMPY_INCLUDE_DIRS
echo $TARGET_NUMPY_INCLUDE_DIRS

export GENERATE_PYTHON_STUBS=1
if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  mkdir -p $TARGET_NUMPY_INCLUDE_DIRS
  cp -r $BUILD_NUMPY_INCLUDE_DIRS/numpy $TARGET_NUMPY_INCLUDE_DIRS
  export GENERATE_PYTHON_STUBS=0
fi

if [[ $OSTYPE == 'darwin'* ]] 
then 
  export BUILD_WITH_ACCELERATE_SUPPORT=1
else
  export BUILD_WITH_ACCELERATE_SUPPORT=0
fi

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DGENERATE_PYTHON_STUBS=$GENERATE_PYTHON_STUBS \
      -DBUILD_WITH_ACCELERATE_SUPPORT=$BUILD_WITH_ACCELERATE_SUPPORT \
      -DPython3_NumPy_INCLUDE_DIR=$TARGET_NUMPY_INCLUDE_DIRS
make -j$(($CPU_COUNT/2))
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/eigenpy/eigenpyTargets.cmake
  rm $PREFIX/lib/cmake/eigenpy/eigenpyTargets.cmake.back
fi
