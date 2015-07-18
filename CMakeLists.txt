cmake_minimum_required(VERSION 2.8.5)

project(Wrapping)

find_package(PythonInterp)
find_package(PythonLibs)

# Setup gccxml, pcre, swig
include(Tools.cmake)

set(output_dir ${CMAKE_CURRENT_BINARY_DIR}/output)
file(MAKE_DIRECTORY ${output_dir})
file(COPY exampleTest.py DESTINATION ${output_dir})

set(cxx_file ${CMAKE_CURRENT_SOURCE_DIR}/example.cxx)
set(cpp_file ${CMAKE_CURRENT_BINARY_DIR}/output/examplePython.cpp)
set(wrap_xxx_file ${CMAKE_CURRENT_BINARY_DIR}/output/wrap_example.cxx)
set(xml_file ${output_dir}/example.xml)
set(idx_file ${output_dir}/example.idx)
set(interface_file ${output_dir}/example.i)
set(python_file ${output_dir}/example.py)
set(lib examplePython) # _name of the final .so file
set(WRAPPER_MODULE_NAME example) # Will be set in wrap_.cxx.in

set(IDX_GENERATOR ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/idx.py)
set(I_GENERATOR ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/igenerator.py)
set(PYGCCXML_DIR ${CMAKE_CURRENT_SOURCE_DIR}/pygccxml)
set(SWIG_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/swig/bin/swig)

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

########## Create the .xml file ##################
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

########## Create the .idx file ##################
add_custom_command(
  OUTPUT ${idx_file}
  COMMAND ${IDX_GENERATOR}
  ${PYGCCXML_DIR} ${GCCXML} ${xml_file} ${idx_file}
  DEPENDS ${IDX_GENERATOR} ${xml_file}
)

########## Create the .i file ####################
add_custom_command(
  OUTPUT ${interface_file}
  COMMAND ${I_GENERATOR}
    -w1 -w3 -w51 -w52 -w53 -w54
    -A protected -A private
    -p ${PYGCCXML_DIR}
    -g ${GCCXML}
    ${xml_file}
    ${interface_file}
  DEPENDS ${idx_file} ${I_GENERATOR}
)

########## Run swig #############################
set(py3arg)
if(PYTHON_VERSION_STRING VERSION_GREATER 3.0)
  set(py3arg "-py3")
endif()
add_custom_command(
    OUTPUT ${cpp_file} ${python_file}
    COMMAND ${SWIG_COMMAND} -c++ -python -O
    ${py3arg}
    -o ${cpp_file}
    -outdir ${output_dir}
    ${interface_file}
    WORKING_DIRECTORY ${output_dir}
    DEPENDS ${interface_file} swig
  )
# swig/bin/swig -c++ -python -O -o output/examplePython.cpp -outdir output output/example.i

# Tell cmake were to put the .so file
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${output_dir})

# Add -I/usr/include/pythonx.y to the /usr/bin/c++ call
# So that Python.h is found
include_directories(${PYTHON_INCLUDE_PATH})

# Compile (example of what is called here):
# /usr/bin/c++ -DExample1_EXPORTS -fPIC -I/usr/include/python2.7 -o CMakeFiles/"${lib}".dir/output/examplePython.cpp.o -c /home/mpopoff/repo/builds/mini-iw/output/examplePython.cpp
add_library("${lib}" MODULE ${cpp_file} ${cxx_file})

# By default we get libexamplePython.so, change this to _examplePython.so
set_target_properties("${lib}" PROPERTIES PREFIX "_")

# Needed ?
target_link_libraries("${lib}" ${PYTHON_LIBRARY})
