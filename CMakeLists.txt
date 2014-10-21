cmake_minimum_required(VERSION 2.8.5)

project(Wrapping)

find_package(PythonInterp)
find_package(PythonLibs)

# Setup gccxml, pcre, swig
include(Tools.cmake)

set(output_dir ${CMAKE_CURRENT_BINARY_DIR}/output)
file(MAKE_DIRECTORY ${output_dir})

set(cxx_file ${CMAKE_CURRENT_SOURCE_DIR}/example.cxx)
set(wrap_xxx_file ${CMAKE_CURRENT_BINARY_DIR}/output/wrap_example.cxx)
set(xml_file ${output_dir}/example.xml)
set(idx_file ${output_dir}/example.idx)

set(IDX_GENERATOR ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/idx.py)
set(PYGCCXML_DIR ${CMAKE_CURRENT_SOURCE_DIR}/pygccxml)

# Define the gcc_xml.inc file, which contains lines with the include paths (-I)
# Set in the itk_wrap_module_gccxml macro in ITK
set(CONFIG_GCCXML_INC_CONTENTS "-I${CMAKE_CURRENT_SOURCE_DIR}\n")
set(CONFIG_GCCXML_INC_CONTENTS "${CONFIG_GCCXML_INC_CONTENTS}-I${PYTHON_INCLUDE_PATH}\n")
set(gccxml_inc_file ${CMAKE_CURRENT_SOURCE_DIR}/output/gcc_xml.inc)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/gcc_xml.inc.in" "${gccxml_inc_file}" @ONLY)

# Automatically set by the itk_wrap_include_gccxml macro in ITK
# (triggered by itk_wrap_class in the .wrap files)
set(GCC_XML_INCLUDES "#include \"example.h\"\n")

configure_file("wrap_.cxx.in" ${wrap_xxx_file} @ONLY)

add_custom_command(
  OUTPUT ${xml_file}
  COMMAND ${GCCXML}
        -fxml-start=_cable_
        -fxml=${xml_file}
        --gccxml-gcc-options ${gccxml_inc_file}
        -DCABLE_CONFIGURATION
        -DITK_MANUAL_INSTANTIATION
        ${wrap_xxx_file}
  DEPENDS ${wrap_xxx_file} ${gccxml_inc_file}
  )

add_custom_command(
  OUTPUT ${idx_file}
  COMMAND ${IDX_GENERATOR}
  ${PYGCCXML_DIR} ${GCCXML} ${xml_file} ${idx_file}
  DEPENDS ${IDX_GENERATOR} ${xml_file}
)

add_custom_target(run ALL DEPENDS ${idx_file})
