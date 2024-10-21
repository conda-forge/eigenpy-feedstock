setlocal EnableDelayedExpansion
set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\share\pkgconfig

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

cmake ^
    %CMAKE_ARGS% ^
    -G Ninja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPYTHON_SITELIB=%SP_DIR% ^
    -DBUILD_TESTING_SCIPY=OFF ^
    -DGENERATE_PYTHON_STUBS=OFF ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release -j1 -v
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Generate Stubs
git clone https://github.com/jcarpent/pybind11-stubgen.git
%PYTHON% "%CD%\pybind11-stubgen\pybind11_stubgen\__init__.py" -o %SP_DIR% eigenpy --boost-python --ignore-invalid signature --no-setup-py --root-module-suffix ""
if errorlevel 1 exit 1
