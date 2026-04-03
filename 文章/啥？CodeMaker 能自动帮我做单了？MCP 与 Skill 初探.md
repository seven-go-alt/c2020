最近几个月，AI coding的能力突飞猛进，冒出一堆认识又不认识的名词。笔者作为一个刚接触这些名词不久的小白，用一个简单的自动做单的案例，探索一下MCP和Skill的用法。

[![](https://kmpvt.pfp.ps.netease.com/file/69ba1b6c6f379bb240c93b0dxZzGWSEF01?sign=mJWmb45oNOjgJx2FvfPLVmVM2XE=&expire=1775208453)](https://km.netease.com/v4/section/gametech?tab=778406184097925&menu=780844158679173)

## 引言

最近 AI Agent 的声音突然变得无限大，一堆似曾相识的名词铺面而来（各种名词祛魅可以看这个[【闪客】一口气拆穿Skill/MCP/RAG/Agent/OpenClaw底层逻辑_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1ojfDBSEPv/?spm_id_from=333.1387.homepage.video_card.click)）。

于是上周在 CodeMaker 上试用了一下，开着 N 个窗口让 N 个机器人吭哧吭哧帮我干活，的确有种莫名的爽感。

这么好用的工具，其他人有什么更加新奇的玩法呢？带着这个问题，我在 KM 上搜索着前辈们的使用经验，无意间点开了公司的 [MCPHUB](https://modelspace.netease.com/mcphub)，看到了 [易协作 MCP Server](https://modelspace.netease.com/mcphub?detail=redmine-mcp-server&namespace=public) 可以让 AI Agent 获取/更新工单信息。

> 「等等， 假如， 我是说假如！假如策划的单描述写的足够详细的话， 岂不是可以让codemaker自动帮我拉单做单拖单一条龙了？」

买不了吃亏，买不了上当。我决定用一个简单的功能单看看能不能跑通这个流程。

---

## 一、MCP 初识：让 AI 长出「手」

### 什么是 MCP？

#### 专业解释

MCP（Model Context Protocol）简单来说就是一个让 AI 能**调用外部工具**的协议。以前的 AI 只能看和说，有了 MCP 就像给它接上了手——可以查工单、改工单、调 API，理论上能干很多事。

在 CodeMaker 中，MCP 以「服务器」的形式存在。比如我们的易协作 MCP Server，就提供了这些能力：

|工具名|能力|
|---|---|
|`get_issue_detail`|获取工单详情|
|`query_issues`|搜索/过滤工单|
|`update_issue`|更新工单（状态、备注、自定义字段等）|
|`get_user_projects`|获取我有权限的项目列表|

#### 个人理解

可以通过 MCP 服务，用温暖的自然语言调用冰冷的工具 API，再把 API 返回结果转换为温暖读的自然语言

### 安装 MCP 服务

既可以在网页上点击链接打开 VS Code 安装，也可以在 CodeMaker 插件里直接安装：  
![Pasted image 20260303203322.png](https://kmpvt.pfp.ps.netease.com/file/69a7b8d05f145761230ac4cc2EuTXm9201?sign=om016Yost4b_E4a37l7fwLngd8o=&expire=1775208453)

### 第一次「拉单」

我先试了个最简单的操作——让 AI 帮我看看我有哪些项目权限：

```undefined
我：看下我有哪个易协作项目的权限
AI：（调用 get_user_projects）→ 您有 H55 项目的权限
```

然后查我手头的开发单：

```routeros
我：看下 H55 项目里，我有哪些开发中的功能单和程序自助单
AI：（调用 query_issues，过滤 status=开发中, assigned_to=me）
    → 找到 #353xxx：RPC反外挂——NPC小游戏是否信任客户端
```

嚯，还真可以，以后哪里还需要去网页上看哦，一个IDE解决所有问题。

> chrome 别打电话来了，我怕codemaker误会。

## 二、从工单到代码的完整流程

接下来，我拿了一张真实的开发单 **#353xxx**，让 AI 从头到尾跑一遍完整流程。

### 2.1 读取工单需求

```1c
我：读取单号 #353xxx 的描述，根据描述开发功能
```

AI 通过 `get_issue_detail` 拉到了工单描述：

> （由于众所周知的原因，单描述里没有单描述。）

为了能让流程走下去，我自己把功能逻辑写在单描述里

> **【功能描述】** xxx功能 是否要完全信任客户端？
> 
> 对于 xxx 小游戏的结束结算流程，分别新增一个开始游戏的 RPC 函数...生成 guuid...校验匹配...不匹配则返回 0...

### 2.2 代码实现

因为是个很简单的功能，代码实现基本没有问题，我额外加了一个需求，根据新增rpc所处的文件位置，生成对应的调用指令：

```powershell
我：在新增rpc后，需要在注释里记录如何用gm指令调用。
如果xxxx, 生成规则：xxxx
如果xxxx, 生成规则：xxxx
```

生成没有问题

```python
@rpc_method(CLIENT_ONLY, (Str("reply_func"),))
def start_music_game(self, reply_func):
    """开始音乐小游戏，生成本局 guuid 并回调给客户端
    GM示例：mdc;;self.call_server_method('start_music_game', 'reply_start_music_game')
    """
    game_guuid = str(IdManager.genid())
    self._music_game_guuid = game_guuid
    self.call_client_method_ex(reply_func, {"guuid": game_guuid})
```

### 2.3 接口文档 + 测试建议

代码改完后，AI 根据需求生成了两份文档：

**RPC 接口变动文档**——包含新增接口的装饰器、函数签名、回调数据格式，以及修改接口的变更说明。

![Pasted image 20260303205656.png](https://kmpvt.pfp.ps.netease.com/file/69a7b95b7591637289a3003cG50WJm9N01?sign=Krtq8LJ830VotE9kjmMO-47XLPA=&expire=1775208453)

> 你就展示一个变动，没有函数最终长啥样，客户端要报警了。

```protobuf
我：rpc接口文档中，新增接口增加展示，规则为，xxxxx

修改接口部分增加展示，新增字段 “接口展示”：xxxx
```

修改后：  
![Pasted image 20260303205848.png](https://kmpvt.pfp.ps.netease.com/file/69a7b9647591637289a3006eefz1hZr201?sign=LYaFJ4r48FZVxEdbqTAU_7aw8H8=&expire=1775208453)

基本符合需求。

**测试建议**——覆盖了正常流程、反外挂校验、跳过 start 直接结算、断线重连、重复结算等多个场景。每条建议都写明了触发方式和预期结果 （这段也是AI自己生成的）。

```sql
测试建议

正常流程：

调用 start_music_game → 收到 guuid → 携带 guuid 调用 record_music_game_result → 确认推理积分、好感度正常发放
调用 start_insect_game → 收到 guuid → 携带 guuid 调用 on_insect_game_end → 确认昆虫图鉴正常更新、好感度正常发放
防外挂校验： 3. 伪造 guuid：跳过 start，直接用随机 guuid 调用结算 → 应拒绝，返回零值，日志出现 guuid mismatch 4. 不调用 start 直接 end：直接调用结算 RPC → 服务端 guuid 为 None，应拒绝 5. 重启后结算：启动游戏后重启服务端，再调用结算 → 内存 guuid 丢失，应被拦截

边界场景： 6. 连续两次 start：服务端以最后一次 guuid 为准，使用第一次 guuid 结算应被拒绝 7. 结算后重用 guuid：成功结算后再次用同一 guuid 调用结算 → 应被拒绝（结算后 guuid 置 None）
```

> 但是感觉只有程序才能看懂，QA黑盒测试看到可能一脸懵逼，生成规则有待打磨。

### 2.4 更新工单

可能是易协作写入请求过多，又或者写入的限制比较严格，连续更新三次都失败了。

AI 先尝试把文档写入我要求的「程序测试建议」自定义字段：

```routeros
update_issue(issue_id=353xxx, custom_field={"56": "..."}) → ❌ 500 Internal Server Error
```

然后再尝试补充到工单描述的【功能描述】末尾：

```routeros
update_issue(issue_id=353xxx, description="...") → ❌ Request timed out
```

超时了。连续重试三次，全部超时。

最后， AI尝试写到工单备注（评论区）：

```routeros
update_issue(issue_id=353xxx, notes="...完整文档...") → ✅ 成功！
```

也就是这个地方  
![Pasted image 20260303205156.png](https://kmpvt.pfp.ps.netease.com/file/69a7b973212fefa7ce758fa406IvdNCF01?sign=y1xVyYRNJW1dYWZC365RUp5ZeTs=&expire=1775208453)

> 你把测试建议写这个地方，QA又要报警了。

### 2.5 git 提交 + 拖单完成

> 感觉有点危险，还是自己来吧。

至此，自动开发功能单的完整流程就算大功告成了。

---

## 三、Skill 初探：一键触发全流程

上面一套流程走下来，除了最初的那句描述之外，过程中我还额外增加了很多提示词来纠正方向。

一想到下次做单又要重复说一遍，头就又大了。

**能不能把这套流程固化下来，下次一句话就跑通？**

有的，兄弟，有的。

流程麻烦不要慌，Skill来帮忙。

### 什么是 Skill？

#### 专业解释

在 CodeMaker 里，存放在项目的 `.codemaker/skills/` 目录下。它定义了：

- **名称和描述**：Skill 是干什么的
- **输入参数**：需要用户提供什么（比如工单号）
- **执行步骤**：AI 应该按什么顺序做什么事
- **规范约束**：代码风格、文档格式、确认节点等

#### 我的理解

用温暖的自然语言调用冰冷的API, 将固化的流程封装起来，一句话触发全流程。

### 那么怎么生成 Skill 呢？

其实我也不会~（摊手）

没关系，有人会就可以。

```sqf
我：根据本次会话内容，帮我生成一个skill, skill名为 auto_issue。 传入参数为单号。让skill完成会话中的全流程

AI:
先梳理本次会话的完整流程，作为 skill 设计的依据：

本次会话全流程：

1. 读取易协作工单详情（get_issue_detail）
2. 解析工单【功能描述】中的开发需求
   ......
```

**更正！！：上面的生成方法不太行**  
用自然语言生成的skill不一定会符合skill规范。如上述语言生成的skill，产生了一个 技能名.mdc的文件，codemaker就无法识别。  
![image.png](https://kmpvt.pfp.ps.netease.com/file/69aa2e35aa53ec536daa5eb35DFhaDCA01?sign=P2d-o4Tf1skIbduJDPciul0R9aU=&expire=1775208453)

> 还是使用skill 生成skill吧 （用魔法生成魔法）

codemaker默认安装了 skill-creator的skill， 可以用`/skill-creator 技能描述` 来创建新skill  
如果已经生成了错误的技能，也可以用 `/skill-creator 把.codemaker.skills下的几个mdc文件转换成skills` 来重新生成  
![image.png](https://kmpvt.pfp.ps.netease.com/file/69aa2f19aa53ec536daa5f53z2oW0Wii01?sign=aDg7eWvAhWaS1ZxRymCAAIq3yl0=&expire=1775208453)

安装好的skill格式如下  
![image.png](https://kmpvt.pfp.ps.netease.com/file/69aa301f763cdcb5edd399c32idaTRBH01?sign=mFIFsYkun_iC-v8p-wIejHl8Fa0=&expire=1775208453)

安装好后重启vscode, 输入/skill名， 就能看到我们生成的skills了  
![image.png](https://kmpvt.pfp.ps.netease.com/file/69aa311db92aa8553547d4e9gU9jQrNr01?sign=bSeJly3mBaT4UxgAXdHlN8aorJY=&expire=1775208453)

### auto_issue

AI自动把本次会话的全流程封装成了一个名为 auto_issue 的 Skill：  
（因为自动更新工单有点危险，所以没加进去）

```yaml
---
name: auto_issue
description: 根据易协作工单号，自动完成从需求分析 → 代码开发 → 文档生成的完整流程。

## 简介
	传入一个易协作工单号，自动完成以下全流程：

	1. 读取工单需求
	2. 分析并确认代码修改方案
	3. 实现代码改动（含 GM 指令注释）
	4. 生成 RPC 接口变动文档 + 测试建议
## 执行步骤

### Step 1：读取工单详情
	xxx

### Step 2：分析代码，制定修改方案

根据工单描述，在代码库中定位相关文件：
- 使用代码搜索定位关键函数
- 分析现有代码结构（函数签名、参数列表、回调逻辑等）
- 制定具体修改方案，**必须向用户展示方案并等待确认**

方案说明应包含：
- 新增/修改的函数列表
- 每个函数的参数变化
- 反外挂/安全校验逻辑设计（如有）
- 是否需要持久化（数据库存储 or 内存存储）

> ⚠️ **在用户确认前不得进行任何代码修改**

---

### Step 3：实现代码改动
	用户确认方案后，按以下规范实施改动：
	#### 3.1 代码规范1
	xxx
	#### 3.2 代码规范2
	xxx
	#### 3.3 注释规范
	xxx

---

### Step 4：生成接口文档与测试建议
代码改动完成后，生成以下两份文档，**展示给用户确认**：

#### 4.1 RPC 接口变动文档
xxx
#### 4.2 测试建议
xxx
---
```

它定义了四个步骤：

|Step|做什么|关键动作|
|---|---|---|
|1|读取工单详情|调用 `get_issue_detail`|
|2|分析代码 + 制定方案|搜索代码库 + **等待用户确认**|
|3|实现代码改动|按规范写代码 + 加 GM 注释|
|4|生成文档|接口变动文档 + 测试建议|

### Skill怎么用？

下次使用时，只需要说：~~芝麻开门（划掉）~~

```angelscript
使用 auto_issue skill，单号 353xxx
```

AI 就会自动走完全流程，并在关键节点停下来等我确认。

### 让我们用 Skill 跑一遍看看

不出意外，这个时候就要出意外了。

#### Round 1

打开新窗口

**我**：使用 auto_issue skill，单号 353xxx

**Claude 4.6 Sonnet**:  
![Pasted image 20260303211119.png](https://kmpvt.pfp.ps.netease.com/file/69a7b9b8ea27cfc381eacb97Go8bQuZb01?sign=86-UaxkLfXrm1BTr2GTdwQV_9U4=&expire=1775208453)

**我**：不是，Step 4 里让你生成的文档呢？还有谁让你去更新工单了？！

**Claude 4.6 Sonnet**：你没说清楚，宝宝心里苦。  
![Pasted image 20260303211407.png](https://kmpvt.pfp.ps.netease.com/file/69a7b9c4ea27cfc381eacbcctN87ygHG01?sign=cMNUu-6KId-O0YwIn2nGbOteTto=&expire=1775208453)

> 好好好，是我的问题，都按你说的来。

#### Round 2

打开新窗口

**我**：使用 auto_issue skill，单号 353xxx

**Claude 4.6 Sonnet**：  
一通操作猛如虎，一看问题更多处。  
在我的质问下，它又开始反思起自己的问题。  
![Pasted image 20260303211517.png](https://kmpvt.pfp.ps.netease.com/file/69a7b9ce4604835ae6c8a0e0Mw6ywUhu01?sign=jZJw13venf_06F_R2UNrsPAExs0=&expire=1775208453)

**我**：等于你的问题还越来越多了？

> 等等，你说不是skill的问题，是你没严格遵守，是AI的问题？
> 
> 懂了，快去西天请来 Opus 老祖！

#### Round 3

打开新窗口，颤颤巍巍地选中 **Claude 4.6 Opus（容量有限）**

**我**：使用 auto_issue skill，单号 353xxx

**Claude 4.6 Opus**：  
![Pasted image 20260303211920.png](https://kmpvt.pfp.ps.netease.com/file/69a7b9dc212fefa7ce7590507hMuRLyM01?sign=y47LTgM6zg3_oTfDja3nJinVpyQ=&expire=1775208453)

这下计划终于对味了。

比较了一下，代码，注释，文档，最终效果，跟最早一句句提示词生成出来的结果几乎完全一样

> 世间万物，贵总有他的道理。  
> ——某次吃饭付钱时，排在前面的女生在编辑的朋友圈

---

## 四、总结与展望

### 这次实验的成果

- ✅ 通过 MCP 成功拉取易协作工单、更新备注
- ✅ AI 自动分析需求、定位代码、实现改动
- ✅ 自动生成接口文档和测试建议
- ✅ 自动封装成可复用的 Skill

### 一些总结

- 可以通过 MCP 服务，用温暖的自然语言调用冰冷的工具 API，再把 API 返回结果转换为温暖读的自然语言。
- 可以通过 Skill，用温暖的自然语言调用冰冷的API, 将固化的流程封装起来，一句话触发全流程。
- Skill 文档可能会越来越大，可以考虑细化拆分——比如生成代码和生成注释分开，各自维护各自的规范。
- 贵的，就是好的。

### 一些展望

因为 AI Agent 可以理解自然语言，以前一些繁重重复的工作完全可以考虑 Skill 化了。

#### （幻想1）查bug

以前：

> QA/运营: 玩家id反馈昨天10点多打完战斗，任务没完成，帮忙查下。
> 
> 我：  
> 打开elk，查看结算p2日志是否挂机，是否强退。  
> 打开策划表，查看这个任务的条件有哪些。  
> 打开loghub，查看日志里战斗传出的数据，传给任务系统的数据，任务系统在哪一步失败了。

将来（幻想）：部署个可以查elk，loghub的mcp。写一个根据不同情形判断任务失败原因的skill。

> QA/运营: 玩家id反馈昨天10点多打完战斗，任务没完成，帮忙查下。
> 
> AI:  
> 调用 ELK mcp: 查询挂机强退情况，未发现违规情况。  
> 查看任务表中任务要求  
> 调用loghub mcp： 查询战斗传出数据，查看传给任务系统数据，查看任务失败原因  
> 已定位原因：玩家未达到此模式特殊需求：存活时长超过xxx秒。实际存活时长xx秒。

#### （幻想2）查负载

过去：

> 压测QA: 压测 xxx功能把游戏服xxx cpu 压爆辣!
> 
> 我: moniter上查看哪个进程超了，  
> postman上看下火焰图，  
> 登录到压测服上看下相关日志，  
> telnet到进程上看下对象数量，  
> 代码里看下相关逻辑。  
> 唔，可能是这块逻辑有问题。

将来（幻想）：

> 压测QA: 压测 xxx功能把游戏服xxx cpu 压爆辣!
> 
> AI :  
> 通过 monitor_mcp 获取 xxx服务器最近20分钟负载情况，xxx~xxx 时间戳期间aaa等进程cpu超过100%，  
> 通过 profile_mcp 获取 xxx服务器 该时段的火焰图数据并分析， xxx函数调用占比60%  
> 通过loghub服务获取该时段日志并分析。  
> 分析本地代码发现未限制该进程的xxx数量， 同时触发xxx更新会导致cpu压力过高。