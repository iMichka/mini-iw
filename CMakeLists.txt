cmake_minimum_required(VERSION 2.8.5)

project(Wrapping)

# Setup gccxml, pcre, swig
include(Tools.cmake)

set(cxx_file ${CMAKE_CURRENT_SOURCE_DIR}/example.cxx)
set(xml_file ${CMAKE_CURRENT_BINARY_DIR}/example.xml)

set(ADDITIONAL_GCC_XML_FLAGS )

set(CONFIG_GCCXML_INC_CONTENTS "")
set(gccxml_inc_file ${CMAKE_CURRENT_SOURCE_DIR}/gcc_xml.inc)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/gcc_xml.inc.in" "${gccxml_inc_file}" @ONLY)

set(ADDITIONAL_GCC_XML_FLAGS "")
if(MSVC90)
  set(ADDITIONAL_GCC_XML_FLAGS "-D\"_HAS_TR1=0\"" )
endif()

#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/wrap_.cxx.in "${cxx_file}" @ONLY)

add_custom_command(
  OUTPUT ${xml_file}
  COMMAND ${GCCXML}
        -fxml-start=_cable_
        -fxml=${xml_file}
        --gccxml-gcc-options ${gccxml_inc_file}
        -DCABLE_CONFIGURATION
        -DITK_MANUAL_INSTANTIATION
        ${ADDITIONAL_GCC_XML_FLAGS}
        ${cxx_file}
  DEPENDS ${cxx_file} ${gccxml_inc_file}
  )

add_custom_target(run ALL DEPENDS ${xml_file})
