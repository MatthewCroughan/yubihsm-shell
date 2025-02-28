include(CheckCCompilerFlag)

if (CMAKE_C_COMPILER_ID STREQUAL "Clang" OR
    CMAKE_C_COMPILER_ID STREQUAL "AppleClang" OR
    CMAKE_C_COMPILER_ID STREQUAL "GNU")

    add_compile_options (-Wall -Wextra -Werror)
    add_compile_options (-Wformat -Wformat-nonliteral -Wformat-security)
    add_compile_options (-Wshadow)
    add_compile_options (-Wcast-qual)
    add_compile_options (-Wmissing-prototypes)
    add_compile_options (-Wbad-function-cast)
    add_compile_options (-pedantic -pedantic-errors)
    add_compile_options (-fpie -fpic)
    if (NOT FUZZ)
        add_compile_options(-O2)
        add_definitions (-D_FORTIFY_SOURCE=2)
    endif ()

    check_c_compiler_flag("-fstack-protector-all" HAVE_STACK_PROTECTOR_ALL)
    if (HAVE_STACK_PROTECTOR_ALL)
        message(STATUS "-fstack-protector-all support detected")
        add_compile_options(-fstack-protector-all)
    else ()
        check_c_compiler_flag("-fstack-protector" HAVE_STACK_PROTECTOR)
        if(HAVE_STACK_PROTECTOR)
            message(STATUS "-fstack-protector support detected")
            add_compile_options(-fstack-protector)
        else ()
            message(WARNING "No stack protection supported.")
        endif ()
    endif ()

    check_c_compiler_flag("-Wno-implicit-fallthrough" HAVE_NO_IMPLICIT_FALLTHROUGH)
    if (HAVE_NO_IMPLICIT_FALLTHROUGH)
        add_compile_options (-Wno-implicit-fallthrough)
    endif ()

    if (NOT CMAKE_C_COMPILER_ID STREQUAL AppleClang)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -pie")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pie")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,noexecstack -Wl,-z,relro,-z,now")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-z,noexecstack -Wl,-z,relro,-z,now")
    endif()
elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    add_compile_options (/GS)
    add_compile_options (/Gs)
    add_link_options (/NXCOMPAT)
    add_link_options (/guard:cf)
else ()
    message(WARNING "Security related flags cannot be set for unknown C compiler.")
endif ()
