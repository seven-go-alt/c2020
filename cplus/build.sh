#!/bin/bash

# C++ 编译快速脚本
# 用法: ./build.sh [命令] [目标]
# 例如: ./build.sh run job_example

set -e

BUILD_DIR="build"
TARGET="${2:-day01}"
SRC_FILE="src/${TARGET}.cpp"
BIN_NAME="${TARGET}"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 显示用法
usage() {
    echo "用法: $0 [命令] [目标]"
    echo ""
    echo "命令:"
    echo "  debug        - 调试模式编译 (带符号和-O0)"
    echo "  release      - 发布模式编译 (带-O3优化)"
    echo "  run          - 编译并运行 (发布模式)"
    echo "  debug-run    - 编译并运行 (调试模式)"
    echo "  clean        - 清理编译产物"
    echo ""
    echo "目标:"
    echo "  day01        - 默认程序"
    echo "  job_example  - 求职示例程序"
    echo ""
    echo "示例:"
    echo "  $0 run job_example"
}

# 检查源文件
check_source() {
    if [ ! -f "$SRC_FILE" ]; then
        echo -e "${RED}错误: 找不到 $SRC_FILE${NC}"
        exit 1
    fi
}

# 创建编译目录
mkdir -p "$BUILD_DIR"

# 处理命令
case "${1:-release}" in
    debug)
        echo -e "${BLUE}[编译] 调试模式: $SRC_FILE${NC}"
        check_source
        clang++ -std=c++17 -Wall -Wextra -Weffc++ -g -O0 -Iinclude "$SRC_FILE" -o "$BUILD_DIR/$BIN_NAME"
        echo -e "${GREEN}✓ 编译完成: $BUILD_DIR/$BIN_NAME${NC}"
        ;;
    release)
        echo -e "${BLUE}[编译] 发布模式: $SRC_FILE${NC}"
        check_source
        clang++ -std=c++17 -Wall -Wextra -Weffc++ -O3 -Iinclude "$SRC_FILE" -o "$BUILD_DIR/$BIN_NAME"
        echo -e "${GREEN}✓ 编译完成: $BUILD_DIR/$BIN_NAME${NC}"
        ;;
    run)
        echo -e "${BLUE}[编译] 发布模式并运行${NC}"
        check_source
        clang++ -std=c++17 -Wall -Wextra -Weffc++ -O3 -Iinclude "$SRC_FILE" -o "$BUILD_DIR/$BIN_NAME"
        echo -e "${GREEN}✓ 编译完成${NC}"
        echo -e "${BLUE}[运行]${NC}"
        ./"$BUILD_DIR/$BIN_NAME"
        ;;
    debug-run)
        echo -e "${BLUE}[编译] 调试模式并运行${NC}"
        check_source
        clang++ -std=c++17 -Wall -Wextra -Weffc++ -g -O0 -Iinclude "$SRC_FILE" -o "$BUILD_DIR/$BIN_NAME"
        echo -e "${GREEN}✓ 编译完成${NC}"
        echo -e "${BLUE}[运行]${NC}"
        ./"$BUILD_DIR/$BIN_NAME"
        ;;
    clean)
        echo -e "${BLUE}[清理]${NC}"
        rm -rf "$BUILD_DIR" *.dSYM
        echo -e "${GREEN}✓ 清理完成${NC}"
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        usage
        exit 1
        ;;
esac
