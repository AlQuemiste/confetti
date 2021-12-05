set(Python3_INTERPRETER_ID     Python)
set(Python3_VERSION_MAJOR      3)
set(Python3_VERSION_MINOR      8)
set(Python3_VERSION_PATCH      10)
# eg. Python3_VERSION = '3.8.10'
set(Python3_VERSION
  ${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}.${Python3_VERSION_PATCH})

set(Python3_EXECUTABLE  ${CMAKE_CURRENT_LIST_DIR}/python.exe)

set(Python3_STDARCH  ${CMAKE_CURRENT_LIST_DIR}/Lib)
set(Python3_STDLIB  ${Python3_STDARCH})

set(Python3_SITEARCH  ${Python3_STDLIB}/site-packages)
set(Python3_SITELIB  ${Python3_SITEARCH})

set(Python3_INCLUDE_DIRS  ${CMAKE_CURRENT_LIST_DIR}/include)
set(Python3_LIBRARY_DIRS  ${CMAKE_CURRENT_LIST_DIR}/libs)
set(Python3_LIBRARIES  ${Python3_LIBRARY_DIRS}/python38.lib)
set(Python3_LIBRARY_RELEASE  ${Python3_LIBRARY_DIRS}/python38.lib)

# set Numpy varialbles
set(Python3_NumPy_VERSION  1.21.4)
set(Python3_NumPy_INCLUDE_DIRS  ${Python3_SITEARCH}/numpy/core/include)

# set *_FOUND variables
set(Python3_FOUND yes)
set(Python3_Interpreter_FOUND yes)
set(Python3_Development_FOUND yes)
set(Python3_NumPy_FOUND yes)
