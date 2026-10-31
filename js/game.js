/* ==========================================================================
   Lucky Spin Casino - 游戏逻辑
   轻量级 HTML5 老虎机，零外部依赖
   ========================================================================== */

(function () {
  "use strict";

  // 游戏配置
  const CONFIG = {
    initialBalance: 1000,
    minBet: 1,
    maxBet: 100,
    defaultBet: 10,
    reelsCount: 3,
    symbolsPerReel: 7,
    spinDuration: 1200, // ms
    stopInterval: 300, // 每个滚轮停止间隔
  };

  // 老虎机图案（按出现概率排序，越前面越常见）
  const SYMBOLS = [
    { emoji: "🍒", name: "樱桃",  multiplier: 5,  weight: 30 },
    { emoji: "🍋", name: "柠檬",  multiplier: 10, weight: 25 },
    { emoji: "🍊", name: "橙子",  multiplier: 15, weight: 20 },
    { emoji: "🍇", name: "葡萄",  multiplier: 20, weight: 15 },
    { emoji: "🔔", name: "铃铛",  multiplier: 50, weight: 7 },
    { emoji: "💎", name: "钻石",  multiplier: 100, weight: 2 },
    { emoji: "7️⃣", name: "幸运 7", multiplier: 500, weight: 1 },
  ];

  // DOM 元素
  const els = {
    balance: document.getElementById("balance"),
    win: document.getElementById("win"),
    bet: document.getElementById("bet"),
    spinBtn: document.getElementById("spin-btn"),
    reels: document.querySelectorAll(".reel"),
    gameMessage: document.getElementById("game-message"),
    symbols: document.querySelectorAll(".symbol"),
  };

  // 游戏状态
  let state = {
    balance: CONFIG.initialBalance,
    bet: CONFIG.defaultBet,
    isSpinning: false,
  };

  // 初始化
  function init() {
    renderBalance();
    renderBet();
    renderWin(0);
    setGameMessage("");

    // 绑定事件
    els.spinBtn.addEventListener("click", handleSpin);
    els.bet.addEventListener("input", handleBetChange);
    els.bet.addEventListener("change", clampBet);

    // 键盘支持：空格或 Enter 滚轮
    document.addEventListener("keydown", (e) => {
      if ((e.key === " " || e.key === "Enter") && !els.spinBtn.disabled) {
        e.preventDefault();
        handleSpin();
      }
    });
  }

  // 处理下注变化
  function handleBetChange() {
    const val = parseInt(els.bet.value, 10) || 0;
    state.bet = val;
    renderBet();
  }

  // 限制下注范围
  function clampBet() {
    let val = parseInt(els.bet.value, 10) || CONFIG.defaultBet;
    if (val < CONFIG.minBet) val = CONFIG.minBet;
    if (val > CONFIG.maxBet) val = CONFIG.maxBet;
    els.bet.value = val;
    state.bet = val;
    renderBet();
  }

  // 渲染余额
  function renderBalance() {
    els.balance.textContent = state.balance.toLocaleString("zh-CN");
    updateSpinButtonState();
  }

  // 渲染下注
  function renderBet() {
    els.bet.value = state.bet;
  }

  // 渲染本局奖金
  function renderWin(amount) {
    els.win.textContent = amount.toLocaleString("zh-CN");
  }

  // 设置游戏消息（无障碍 aria-live 区域）
  function setGameMessage(text, type = "") {
    els.gameMessage.textContent = text;
    els.gameMessage.className = "game-message" + (type ? " " + type : "");
  }

  // 更新旋转按钮状态
  function updateSpinButtonState() {
    const canSpin = !state.isSpinning && state.balance >= state.bet;
    els.spinBtn.disabled = !canSpin;
    els.spinBtn.setAttribute("aria-disabled", String(!canSpin));
  }

  // 加权随机选择图案索引
  function pickSymbolIndex() {
    const totalWeight = SYMBOLS.reduce((sum, s) => sum + s.weight, 0);
    let random = Math.random() * totalWeight;
    for (let i = 0; i < SYMBOLS.length; i++) {
      random -= SYMBOLS[i].weight;
      if (random <= 0) return i;
    }
    return SYMBOLS.length - 1;
  }

  // 生成一个滚轮的最终停止符号索引（3个可见位置）
  function generateReelStop() {
    return [pickSymbolIndex(), pickSymbolIndex(), pickSymbolIndex()];
  }

  // 主旋转逻辑
  async function handleSpin() {
    if (state.isSpinning) return;
    if (state.balance < state.bet) {
      setGameMessage("余额不足，请降低下注金额。", "loss");
      return;
    }

    // 扣除下注
    state.balance -= state.bet;
    state.isSpinning = true;
    updateSpinButtonState();
    renderBalance();
    renderWin(0);
    setGameMessage("旋转中…");

    // 滚轮动画：每个滚轮依次启动与停止
    const reelResults = [];
    for (let i = 0; i < CONFIG.reelsCount; i++) {
      reelResults.push(generateReelStop());
    }

    // 依次让每个滚轮“转动”
    for (let i = 0; i < CONFIG.reelsCount; i++) {
      els.reels[i].classList.add("spinning");
      await sleep(CONFIG.stopInterval);
    }

    // 停止每个滚轮（反向顺序，增加悬念）
    for (let i = CONFIG.reelsCount - 1; i >= 0; i--) {
      els.reels[i].classList.remove("spinning");
      setReelSymbols(i, reelResults[i]);
      await sleep(CONFIG.stopInterval);
    }

    // 计算结果
    const topSymbols = reelResults.map((r) => r[0]); // 只看中间行（索引 0 作为获胜行）
    const result = evaluateWin(topSymbols);

    // 结算
    if (result.won) {
      state.balance += result.payout;
      renderBalance();
      renderWin(result.payout);
      highlightWinningSymbols(result.winningIndices);
      setGameMessage(`恭喜！赢取 ${result.payout.toLocaleString("zh-CN")} 虚拟金币！`, "win");
    } else {
      renderWin(0);
      setGameMessage("未中奖，再试一次！", "loss");
    }

    state.isSpinning = false;
    updateSpinButtonState();
  }

  // 设置滚轮显示的符号（从顶部开始显示 3 个）
  function setReelSymbols(reelIndex, symbolIndices) {
    const reel = els.reels[reelIndex];
    const symbols = reel.querySelectorAll(".symbol");
    symbols.forEach((sym, idx) => {
      const symbolIdx = symbolIndices[idx % symbolIndices.length];
      const symbol = SYMBOLS[symbolIdx];
      sym.dataset.symbol = symbol.emoji;
      sym.textContent = symbol.emoji;
      sym.setAttribute("aria-label", `${symbol.name} (${symbol.emoji})`);
      sym.classList.remove("winning");
    });
  }

  // 评估胜负（3 个滚轮顶部符号相同即中奖）
  function evaluateWin(topSymbols) {
    const first = topSymbols[0];
    const allSame = topSymbols.every((s) => s === first);

    if (allSame) {
      const symbolIdx = SYMBOLS.findIndex((s) => s.emoji === first);
      const payout = SYMBOLS[symbolIdx].multiplier * state.bet;
      return {
        won: true,
        payout,
        winningIndices: [0, 1, 2],
      };
    }

    return { won: false, payout: 0, winningIndices: [] };
  }

  // 高亮中奖符号
  function highlightWinningSymbols(indices) {
    indices.forEach((reelIdx) => {
      const reel = els.reels[reelIdx];
      const firstSymbol = reel.querySelector(".symbol");
      firstSymbol.classList.add("winning");
    });
  }

  // 工具：sleep
  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  // 页面加载后初始化
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();