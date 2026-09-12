set(PYTHON_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
#------------------------------------------------------------------------------#
# Returns artifact version.
#
# The name of function must consist of folder name (python) and postfix 
# (_GetArtifactVersion). Otherwise the buildprocess will fail.  
#
# ARTIFACT_VERSION [out]: Version of artifact in format X.Y.Z
#------------------------------------------------------------------------------#
function(python_GetArtifactVersion RET_VERSION)

    if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
        execute_process(COMMAND python --version
                        OUTPUT_VARIABLE ARTIFACT_VERSION
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
    else()
        execute_process(COMMAND python3 --version
                        OUTPUT_VARIABLE ARTIFACT_VERSION
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()

    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" VERSION "${ARTIFACT_VERSION}")

    set(${RET_VERSION} "${VERSION}" PARENT_SCOPE)

endfunction()


#------------------------------------------------------------------------------#
# Initialize artifact for build.
#
# The name of function must consist of folder name (python) and postfix 
# (_ArtifactInit). Otherwise the buildprocess will fail.  
#
# ARTIFACT_BIN_PATH_ARG [in]: Path to the binary part of artifact
#------------------------------------------------------------------------------#
function(python_ArtifactInit ARTIFACT_BIN_PATH_ARG)

    if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")

        file(GLOB_RECURSE ALL_CONFIG_FILES "${ARTIFACT_BIN_PATH_ARG}/*python.exe")

        foreach(FILE_PATH IN LISTS ALL_CONFIG_FILES)
            if(FILE_PATH MATCHES "python.exe")
                get_filename_component(CONFIG_DIR ${FILE_PATH} DIRECTORY)
                break()
            endif()
        endforeach()

        if(CONFIG_DIR)

            message(STATUS "File python.exe found in: ${CONFIG_DIR}")

            set(ENV{PATH} "${CONFIG_DIR};$ENV{PATH}")

            # pip.exe / pip3.exe live in a sibling "Scripts" directory on
            # Windows (standard CPython install layout), not next to
            # python.exe itself - add it too if present.
            if(EXISTS "${CONFIG_DIR}/Scripts")
                set(ENV{PATH} "${CONFIG_DIR}/Scripts;$ENV{PATH}")
            endif()

        else()

            message(FATAL_ERROR "File python.exe not found.")

        endif()

    else()

        file(GLOB_RECURSE ALL_CONFIG_FILES "${ARTIFACT_BIN_PATH_ARG}/*python3")

        foreach(FILE_PATH IN LISTS ALL_CONFIG_FILES)
            if(FILE_PATH MATCHES "python3")
                get_filename_component(CONFIG_DIR ${FILE_PATH} DIRECTORY)
                break()
            endif()
        endforeach()

        if(CONFIG_DIR)

            message(STATUS "File python3 found in: ${CONFIG_DIR}")

            # pip3 is co-located with python3 in the same bin/ directory on
            # Linux and macOS (standard CPython install layout) - no
            # separate PATH entry needed.
            set(ENV{PATH} "${CONFIG_DIR}:$ENV{PATH}")

        else()

            message(FATAL_ERROR "File python3 not found.")

        endif()

    endif()

    message(DEBUG "Python interpreter directory added to PATH: ${CONFIG_DIR}")

endfunction()
