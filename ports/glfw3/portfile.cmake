include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glfw-3.2.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/glfw/glfw/releases/download/3.2.1/glfw-3.2.1.zip"
    FILENAME "glfw-3.2.1.zip"
    SHA512 73dd6d4a8d28a2b423f0fb25489659c1a845182b7ef09848d4f442cdc489528aea90f43ac84aeedb9d2301c4487f39782b647ee4959e67e83babb838372b980c
)
vcpkg_extract_source_archive(${ARCHIVE})

if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/patch.stamp)
    file(READ ${SOURCE_PATH}/src/glfw3Config.cmake.in CONFIG)
    string(REPLACE "\"@GLFW_LIB_NAME@\"" "NAMES @GLFW_LIB_NAME@ @GLFW_LIB_NAME@dll"
        CONFIG ${CONFIG}
    )
    string(REPLACE "@PACKAGE_CMAKE_INSTALL_PREFIX@" "@PACKAGE_CMAKE_INSTALL_PREFIX@/../.."
        CONFIG ${CONFIG}
    )
    file(WRITE ${SOURCE_PATH}/src/glfw3Config.cmake.in ${CONFIG})
    file(APPEND ${SOURCE_PATH}/src/glfw3Config.cmake.in "set(GLFW3_LIBRARIES \${GLFW3_LIBRARY})\n")
    file(WRITE ${CURRENT_BUILDTREES_DIR}/patch.stamp)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
        -DPACKAGE_CMAKE_INSTALL_PREFIX=\${CMAKE_CURRENT_LIST_DIR}/../..
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/share
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/glfw3.dll ${CURRENT_PACKAGES_DIR}/bin/glfw3.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/glfw3.dll ${CURRENT_PACKAGES_DIR}/debug/bin/glfw3.dll)

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/glfw3 ${CURRENT_PACKAGES_DIR}/share/glfw3)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/glfw3/glfw3Targets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/glfw3/glfw3Targets-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/glfw3.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/glfw3.lib)

file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glfw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glfw3/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/glfw3/copyright)
vcpkg_copy_pdbs()

