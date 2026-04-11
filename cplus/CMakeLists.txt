cmake_minimum_required(VERSION 3.15)
project(CppLearning)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Weffc++")

# 调试和发布模式
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 包含头文件目录
include_directories(${PROJECT_SOURCE_DIR}/include)

# 源文件列表
set(SOURCES
    src/day01.cpp
)

# 创建可执行文件
add_executable(day01 ${SOURCES})

# 优化选项
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(day01 PRIVATE -g -O0)
else()
    target_compile_options(day01 PRIVATE -O3)
endif()
