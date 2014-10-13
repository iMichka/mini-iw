cmake_minimum_required(VERSION 2.8.5)

project(Wrapping)

# Setup gccxml, pcre, swig
include(Tools.cmake)

set(cxx_file ${CMAKE_CURRENT_SOURCE_DIR}/example.cxx)
set(xml_file ${CMAKE_CURRENT_BINARY_DIR}/example.xml)

set(gccxml_inc_file )
set(ADDITIONAL_GCC_XML_FLAGS )

#set(gccxml_inc_file "${WRAPPER_LIBRARY_OUTPUT_DIR}/gcc_xml.inc")

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
