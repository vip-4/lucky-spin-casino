# 轻量级静态游戏部署规划

> 基于当前技术栈（HTML/CSS/JS，静态托管，SEO/GEO 优化），精选适合在 Cloudflare Pages / Netlify / Vercel / GitHub Pages 上部署的轻量级游戏。

## 选型标准

1. **纯前端**：仅 HTML/CSS/JavaScript，无后端、无数据库
2. **体积小**：单个游戏总资源 < 5MB（理想 < 1MB），加载时间 < 2s
3. **自包含**：无外部 CDN 依赖（或仅用国内可访问的 CDN），离线可玩
4. **多端适配**：响应式 + 触屏支持 + 键盘控制
5. **SEO/GEO 友好**：可注入 meta、结构化数据、FAQ、HowTo

---

## 一、益智类 (Puzzle)

### 1. 2048
- **描述**：滑动合并相同数字方块，目标合成 2048。经典益智，规则简单，上手即玩。
- **技术难点**：滑动动画与合并逻辑、触摸手势识别、Undo/Redo 历史栈、Local Storage 最高分持久化
- **建议库**：纯原生 JS（~2KB 核心逻辑）；动画用 CSS Transform + Transition
- **体积**：~50KB（含 CSS）
- **开源参考**：[gabrielecirulli/2048](https://github.com/gabrielecirulli/2048) (11k stars)

### 2. 滑动拼图 (Sliding Puzzle / 15-Puzzle)
- **描述**：将打乱的数字/图片方块滑回正确顺序。可扩展为图片拼图模式。
- **技术难点**：A* 算法生成可解打乱、拖拽/点击交互、图片裁切与背景定位
- **建议库**：原生 JS + CSS Grid；可选 `gsap` 做平滑动画
- **体积**：~80KB

### 3. 数独 (Sudoku)
- **描述**：9×9 数字填充，经典逻辑推理。支持难度分级与提示。
- **技术难点**：回溯算法生成/求解、唯一解验证、冲突高亮、键盘输入
- **建议库**：原生 JS；可选 `sudoku.js`（开源生成器）
- **体积**：~100KB
- **开源参考**：[MicrosoftEdge/Sudoku](https://github.com/MicrosoftEdge/Sudoku)

### 4. 俄罗斯方块 (Tetris)
- **描述**：下落方块旋转拼接，消除满行。经典街机玩法。
- **技术难点**：SRS 旋转系统、T-Spin 检测、7-bag 随机、幽灵方块、DAS/ARR 输入处理、Canvas 渲染
- **建议库**：原生 Canvas API；可选 `tetris` npm 包参考
- **体积**：~120KB
- **开源参考**：[simonlc/tetr.js](https://github.com/simonlc/tetr.js)

### 5. 井字棋 (Tic-Tac-Toe)
- **描述**：3×3 棋盘，两人轮流落子。可扩展为 AI 对战（Minimax）。
- **技术难点**：Minimax + Alpha-Beta 剪枝 AI、胜利检测、平局判断
- **建议库**：纯原生 JS（~10KB）
- **开源参考**：[ramazancetinkaya/tictactoe](https://github.com/ramazancetinkaya/tictactoe)

### 6. 连连看 / 记忆翻牌 (Memory Card Game)
- **描述**：翻牌配对，考验记忆力。支持多难度与计时。
- **技术难点**：洗牌算法（Fisher-Yates）、翻牌动画（CSS 3D transform）、计时器与计分
- **建议库**：原生 JS + CSS 3D
- **体积**：~60KB
- **开源参考**：[mmenavas/memory-game](https://github.com/mmenavas/memory-game)

### 7. 推箱子 (Sokoban)
- **描述**：推动箱子到目标点，经典解谜。关卡编辑器可选。
- **技术难点**：关卡数据结构、撤销/重做、碰撞检测、关卡进度保存
- **建议库**：原生 JS + Canvas 或 DOM
- **体积**：~80KB

---

## 二、动作类 (Action)

### 8. 贪吃蛇 (Snake)
- **描述**：控制蛇移动吃食物，身体增长，避免撞墙/自身。
- **技术难点**：游戏循环（requestAnimationFrame）、方向队列防反向、碰撞检测、触摸滑动控制
- **建议库**：原生 Canvas API
- **体积**：~40KB
- **开源参考**：[CodeExplainedRepo/Snake-JavaScript](https://github.com/CodeExplainedRepo/Snake-JavaScript)

### 9. 打砖块 (Breakout / Arkanoid)
- **描述**：控制挡板反弹小球，击碎砖块。可加入道具系统。
- **技术难点**：圆-矩形碰撞检测、小球速度向量、砖块生命值、道具掉落
- **建议库**：原生 Canvas API
- **体积**：~80KB

### 10. 乒乓球 (Pong)
- **描述**：双人/人机对战乒乓球。经典街机。
- **技术难点**：AI 难度分级、球速递增、碰撞物理
- **建议库**：原生 Canvas API
- **开源参考**：[CodeExplainedRepo/Ping-Pong-Game-JavaScript](https://github.com/CodeExplainedRepo/Ping-Pong-Game-JavaScript)

### 11. Flappy Bird 风格 (Dino Runner)
- **描述**：点击/空格跳跃，避开障碍物，无尽跑酷。
- **技术难点**：抛物线跳跃物理、障碍物生成与回收、速度渐增、视差背景
- **建议库**：原生 Canvas API
- **体积**：~60KB

### 12. 打地鼠 (Whack-a-Mole)
- **描述**：地鼠随机出现，点击得分。限时挑战。
- **技术难点**：随机出现算法、计时器、连击计分、难度递增
- **建议库**：原生 JS + CSS Animation
- **体积**：~40KB

---

## 三、休闲类 (Casual / Arcade)

### 13. 三消 (Match-3)
- **描述**：交换相邻宝石，形成 3+ 连线消除，类似 Candy Crush。
- **技术难点**：匹配检测算法、连锁消除（cascade）、下落填充、动画时序管理
- **建议库**：原生 Canvas/DOM；可选 `gsap` 做消除动画
- **体积**：~150KB
- **开源参考**：[rembound/Match-3-Game-HTML5](https://github.com/rembound/Match-3-Game-HTML5)

### 14. 五子棋 (Gomoku)
- **描述**：15×15 棋盘，五子连珠获胜。支持人机对战。
- **技术难点**：Minimax + 评估函数、禁手规则（可选）、棋型识别
- **建议库**：原生 JS + Canvas
- **体积**：~100KB

### 15. 四子棋 (Connect Four)
- **描述**：竖版落子，四子连珠获胜。
- **技术难点**：列满检测、胜利检测（4 方向）、AI 对手
- **建议库**：原生 JS
- **开源参考**：[caleb531/connect-four](https://github.com/caleb531/connect-four)

### 16. 21 点 (Blackjack)
- **描述**：经典赌场纸牌游戏，与庄家比点数。
- **技术难点**：发牌逻辑、A 牌软/硬值计算、庄家 AI 规则、下注系统
- **建议库**：原生 JS + CSS
- **体积**：~80KB

### 17. 猜拳 (Rock Paper Scissors)
- **描述**：剪刀石头布，可扩展为 lizard/spock 变体。
- **技术难点**：简单，适合入门；可加入 AI 预测（基于历史）
- **建议库**：原生 JS
- **开源参考**：[milsaware/javascript-rock-paper-scissors](https://github.com/milsaware/javascript-rock-paper-scissors)

---

## 四、策略/棋类 (Strategy / Board)

### 18. 象棋 (Chinese Chess / Xiangqi)
- **描述**：中国传统棋类，10×9 棋盘。需实现完整规则。
- **技术难点**：棋子移动规则、将军/将死检测、AI 引擎（Minimax + 评估）、悔棋
- **建议库**：原生 JS + Canvas
- **体积**：~200KB

### 19. 国际象棋 (Chess)
- **描述**：8×8 棋盘，完整规则（含吃过路兵、王车易位、升变）。
- **技术难点**：复杂移动规则、AI 引擎（可用 `chess.js` + `stockfish.js` WASM）
- **建议库**：`chess.js`（规则引擎）+ `chessboard.js`（棋盘 UI）或纯原生
- **体积**：~300KB（含 chess.js）

### 20. 跳棋 (Checkers / Draughts)
- **描述**：斜向移动与跳跃吃子。
- **技术难点**：跳跃链检测、AI 对手
- **建议库**：原生 JS
- **开源参考**：[bocaletto-luca/Dama](https://github.com/bocaletto-luca/Dama)

---

## 五、其他轻量游戏

### 21. 猜单词 (Hangman)
- **描述**：猜字母组成单词，错误次数有限。
- **技术难点**：单词库、键盘输入、SVG/Canvas 绘制绞刑架
- **建议库**：原生 JS
- **开源参考**：[abdoutech19/hangman-game](https://github.com/abdoutech19/hangman-game)

### 22. 反应测试 (Reaction Time Test)
- **描述**：屏幕变色后点击，测量反应时间。可做排行榜。
- **技术难点**：随机延迟、防作弊（提前点击）、统计分析
- **建议库**：原生 JS
- **体积**：~20KB

### 23. 打字练习 (Typing Speed Test)
- **描述**：计时打字，计算 WPM 和准确率。
- **技术难点**：实时输入处理、错误高亮、WPM 计算
- **建议库**：原生 JS
- **体积**：~30KB

---

## 推荐部署优先级

### 第一批（高人气、实现简单、SEO 友好）
1. **2048** — 极简、 viral、SEO 友好
2. **贪吃蛇 (Snake)** — 经典、移动端友好
3. **俄罗斯方块 (Tetris)** — 高留存
4. **记忆翻牌 (Memory)** — 无障碍友好
5. **打砖块 (Breakout)** — 街机经典

### 第二批（玩法丰富、可扩展）
6. **三消 (Match-3)** — 高 DAU 潜力
7. **数独 (Sudoku)** — 每日挑战模式
8. **21 点 (Blackjack)** — 赌场主题协同
9. **Flappy Bird 风格** — 快节奏、高分享率
10. **推箱子 (Sokoban)** — 关卡制、长尾流量

### 第三批（复杂度较高、差异化）
11. **国际象棋 (Chess)** — 需 chess.js
12. **象棋 (Xiangqi)** — 中国市场
13. **五子棋 (Gomoku)** — 简单 AI
14. **扫雷 (Minesweeper)** — 经典

---

## 通用技术栈建议

| 层级 | 推荐方案 |
|------|---------|
| 渲染 | Canvas 2D（动作类）/ DOM + CSS（益智类） |
| 动画 | CSS Transitions/Animations（轻量）或 GSAP（复杂） |
| 音效 | Web Audio API（合成音效，无外部文件） |
| 存储 | LocalStorage（最高分、进度） |
| PWA | manifest.json + Service Worker（离线可玩） |
| SEO | 每个游戏独立页面 + meta + JSON-LD (GameApplication) |
| 构建 | 无构建（纯静态）或 Vite（多页面） |

## 部署策略

- **每个游戏独立子域名**：`2048.vip01.cc.cd`、`snake.vip01.cc.cd` 等
- **或统一游戏门户**：`games.vip01.cc.cd/2048`、`/snake` 等（共享导航与 SEO 权重）
- **推荐门户模式**：统一域名，共享 header/footer/SEO，降低 DNS/路由配置复杂度
- **每个游戏独立页面**：便于搜索引擎索引与 AI 摘要引用

## 下一步行动

1. 选择 3-5 个第一批游戏进行原型开发
2. 为每个游戏创建独立目录（如 `games/2048/`、`games/snake/`）
3. 统一 SEO/GEO 模板（meta、JSON-LD、FAQ、HowTo）
4. 部署到 Cloudflare Pages（复用现有 CI/CD 流水线）
5. 提交 sitemap 到 Google/Bing/Baidu

---

*本规划基于对 GitHub 开源游戏生态的调研，所有推荐游戏均为 MIT/Apache 等宽松协议，可自由修改与部署。*