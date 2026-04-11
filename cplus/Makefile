.PHONY: all build clean run debug

# 编译器和标志
CXX := clang++
CXXFLAGS := -std=c++17 -Wall -Wextra -Weffc++
DEBUG_FLAGS := -g -O0
RELEASE_FLAGS := -O3

# 目录
SRC_DIR := src
BIN_DIR := build
INCLUDE := -Iinclude

# 源文件和目标文件
SOURCES := $(wildcard $(SRC_DIR)/*.cpp)
TARGETS := $(patsubst $(SRC_DIR)/%.cpp,$(BIN_DIR)/%,$(SOURCES))

# 默认目标
all: release

# 发布版本（优化）
release: CXXFLAGS += $(RELEASE_FLAGS)
release: $(TARGETS)

# 调试版本
debug: CXXFLAGS += $(DEBUG_FLAGS)
debug: $(TARGETS)

# 编译规则
$(BIN_DIR)/%: $(SRC_DIR)/%.cpp
	@mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $< -o $@

# 运行主程序
run: release
	./$(BIN_DIR)/day01

# 运行调试版本
debug-run: debug
	./$(BIN_DIR)/day01

# 清理编译产物
clean:
	rm -rf $(BIN_DIR)
	rm -rf *.dSYM

# 帮助信息
help:
	@echo "可用命令："
	@echo "  make release    - 编译发布版本（默认）"
	@echo "  make debug      - 编译调试版本"
	@echo "  make run        - 编译并运行发布版本"
	@echo "  make debug-run  - 编译并运行调试版本"
	@echo "  make clean      - 清理编译产物"
	@echo "  make help       - 显示此帮助信息"
