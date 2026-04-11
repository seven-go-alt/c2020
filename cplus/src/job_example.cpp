#include <cassert>
#include <iostream>
#include <list>
#include <unordered_map>
#include <vector>

class LRUCache {
public:
    explicit LRUCache(int capacity) : capacity_(capacity) {}

    int get(int key) {
        auto it = cache_.find(key);
        if (it == cache_.end()) {
            return -1;
        }
        // 将访问的元素移动到链表头部，表示最近使用
        items_.splice(items_.begin(), items_, it->second);
        return it->second->second;
    }

    void put(int key, int value) {
        auto it = cache_.find(key);
        if (it != cache_.end()) {
            // 已存在，更新值并移动到头部
            it->second->second = value;
            items_.splice(items_.begin(), items_, it->second);
            return;
        }

        if ((int)items_.size() == capacity_) {
            // 删除最久未使用的元素
            auto last = items_.back();
            cache_.erase(last.first);
            items_.pop_back();
        }

        items_.emplace_front(key, value);
        cache_[key] = items_.begin();
    }

private:
    int capacity_;
    std::list<std::pair<int, int>> items_;
    std::unordered_map<int, std::list<std::pair<int, int>>::iterator> cache_;
};

void TestLRUCache() {
    LRUCache cache(2);
    cache.put(1, 1);
    cache.put(2, 2);
    assert(cache.get(1) == 1); // 返回 1

    cache.put(3, 3);          // 使 key 2 被淘汰
    assert(cache.get(2) == -1);

    cache.put(4, 4);          // 使 key 1 被淘汰
    assert(cache.get(1) == -1);
    assert(cache.get(3) == 3);
    assert(cache.get(4) == 4);

    cache.put(4, 40);         // 更新现有 key
    assert(cache.get(4) == 40);

    cache.put(5, 5);          // 使 key 3 被淘汰
    assert(cache.get(3) == -1);
    assert(cache.get(4) == 40);
    assert(cache.get(5) == 5);

    std::cout << "LRUCache 测试通过。" << std::endl;
}

int main() {
    std::cout << "求职调试示例: LRUCache" << std::endl;
    TestLRUCache();

    std::cout << "示例程序运行结束。" << std::endl;
    return 0;
}
