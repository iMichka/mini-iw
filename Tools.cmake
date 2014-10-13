set(gccxml_url http://itk.org/files/gccxml/gccxml-2014-08-06.tar.bz2)
set(gccxml_md5 8c72fef316e7fa5deae970ca487c2816)

set(swig_url   http://prdownloads.sourceforge.net/swig/swig-3.0.2.tar.gz)
set(swig_md5   62f9b0d010cef36a13a010dc530d0d41)

set(pcre_url   http://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.gz)
set(pcre_md5   ff7b4bb14e355f04885cf18ff4125c98)

include(ExternalProject)

# Build GCCXML
ExternalProject_Add(GCC_XML
  URL ${gccxml_url}
  URL_MD5 ${gccxml_md5}
  PREFIX gccxml
  CMAKE_ARGS
    -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_COMPILER_ARG1:STRING=${CMAKE_CXX_COMPILER_ARG1}
    -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
    -DCMAKE_C_COMPILER_ARG1:STRING=${CMAKE_C_COMPILER_ARG1}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
    -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/gccxml/
    -DBUILD_TESTING:BOOL=OFF
  STEP_TARGETS install
  )
set(GCCXML ${CMAKE_CURRENT_BINARY_DIR}/gccxml/bin/gccxml CACHE FILEPATH "GCCXML executable." FORCE)

# Build PCRE
ExternalProject_Add(PCRE
    URL ${pcre_url}
    URL_MD5 ${pcre_md5}
    CONFIGURE_COMMAND
      env
        "CC=${CMAKE_C_COMPILER} ${CMAKE_C_COMPILER_ARG1}"
        "CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}"
        "LDFLAGS=$ENV{LDFLAGS}"
        "LIBS=$ENV{LIBS}"
        "CPPFLAGS=$ENV{CPPFLAGS}"
        "CXX=${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1}"
        "CXXFLAGS=${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}"
        "CPP=$ENV{CPP}"
        "CXXPP=$ENV{CXXPP}"
      ../PCRE/configure
      --prefix=${CMAKE_CURRENT_BINARY_DIR}/PCRE
      --enable-shared=no
    )

# Swig uses bison find it by cmake and pass it down
find_package(BISON)
set(BISON_FLAGS "" CACHE STRING "Flags used by bison")
mark_as_advanced(BISON_FLAGS)

ExternalProject_Add(swig
    URL ${swig_url}
    URL_MD5 ${swig_md5}
    CONFIGURE_COMMAND
      env
        "CC=${CMAKE_C_COMPILER} ${CMAKE_C_COMPILER_ARG1}"
        "CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}"
        "LDFLAGS=$ENV{LDFLAGS}"
        "LIBS=$ENV{LIBS}"
        "CPPFLAGS=$ENV{CPPFLAGS}"
        "CXX=${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1}"
        "CXXFLAGS=${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}"
        "CPP=$ENV{CPP}"
        "YACC=${BISON_EXECUTABLE}"
        "YFLAGS=${BISON_FLAGS}"
      ../swig/configure
      --prefix=${CMAKE_CURRENT_BINARY_DIR}/swig
      --with-pcre-prefix=${CMAKE_CURRENT_BINARY_DIR}/PCRE
    DEPENDS PCRE
    )
