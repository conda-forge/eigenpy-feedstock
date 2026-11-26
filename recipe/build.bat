mkdir build
cd build

cmake ^
    %CMAKE_ARGS% ^
    -G Ninja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython_EXECUTABLE=%PYTHON% ^
    -DBUILD_TESTING_SCIPY=OFF ^
    -DGENERATE_PYTHON_STUBS=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release -j1 -v
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
