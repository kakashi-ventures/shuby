import { Controller } from "@hotwired/stimulus"

const MAX_LINES = 200
const TURBO_EVENTS = [
  "turbo:click",
  "turbo:before-visit",
  "turbo:visit",
  "turbo:before-fetch-request",
  "turbo:before-fetch-response",
  "turbo:fetch-request-error",
  "turbo:load",
  "turbo:render",
  "turbo:frame-missing",
  "turbo:submit-start",
  "turbo:submit-end"
]

export default class extends Controller {
  connect() {
    this.lines = []
    this.mount()
    this.boundClick = this.logClick.bind(this)
    this.boundTurbo = this.logTurbo.bind(this)

    document.addEventListener("click", this.boundClick, true)
    TURBO_EVENTS.forEach(t => document.addEventListener(t, this.boundTurbo))
    this.wrapBridge()
    this.snapshot()
  }

  disconnect() {
    document.removeEventListener("click", this.boundClick, true)
    TURBO_EVENTS.forEach(t => document.removeEventListener(t, this.boundTurbo))
    this.unwrapBridge()
    this.wrap?.remove()
    this.styleEl?.remove()
  }

  mount() {
    const style = document.createElement("style")
    style.textContent = `
      .shuby-debug-panel-wrap{position:fixed;left:4px;right:4px;bottom:max(60px,env(safe-area-inset-bottom,0px));z-index:2147483647;font:11px/1.35 ui-monospace,Menlo,monospace;color:#fff;background:rgba(0,0,0,.78);border-radius:8px;max-height:50vh;display:flex;flex-direction:column}
      .shuby-debug-panel-bar{display:flex;gap:6px;align-items:center;padding:4px 8px;border-bottom:1px solid rgba(255,255,255,.15);font-weight:600}
      .shuby-debug-panel-bar button{background:rgba(255,255,255,.12);color:#fff;border:0;padding:2px 8px;border-radius:4px;font:inherit;cursor:pointer}
      .shuby-debug-panel-log{overflow:auto;padding:4px 8px;flex:1;white-space:pre-wrap;word-break:break-all}
      .shuby-debug-panel-log div{padding:1px 0;border-bottom:1px dotted rgba(255,255,255,.08)}
      .shuby-debug-panel-log .err{color:#ff8080}
      .shuby-debug-panel-log .brg{color:#80c8ff}
      .shuby-debug-panel-log .trb{color:#ffd080}
      .shuby-debug-panel-log .clk{color:#80ffb0}
      .shuby-debug-panel-collapsed .shuby-debug-panel-log{display:none}
      .shuby-debug-panel-collapsed{max-height:none}
    `
    document.head.appendChild(style)
    this.styleEl = style

    const wrap = document.createElement("div")
    wrap.className = "shuby-debug-panel-wrap"

    const bar = document.createElement("div")
    bar.className = "shuby-debug-panel-bar"

    const title = document.createElement("span")
    title.textContent = "DEBUG"
    title.style.flex = "1"
    bar.appendChild(title)

    const mkBtn = (act, label) => {
      const b = document.createElement("button")
      b.type = "button"
      b.dataset.act = act
      b.textContent = label
      return b
    }
    bar.appendChild(mkBtn("toggle", "▾"))
    bar.appendChild(mkBtn("clear", "clear"))
    bar.appendChild(mkBtn("copy", "copy"))

    const log = document.createElement("div")
    log.className = "shuby-debug-panel-log"

    wrap.appendChild(bar)
    wrap.appendChild(log)
    document.body.appendChild(wrap)

    this.wrap = wrap
    this.logEl = log
    bar.addEventListener("click", (e) => {
      const act = e.target.closest("button")?.dataset.act
      if (!act) return
      e.stopPropagation()
      if (act === "toggle") wrap.classList.toggle("shuby-debug-panel-collapsed")
      if (act === "clear") { this.lines = []; this.logEl.textContent = "" }
      if (act === "copy") this.copy()
    })
  }

  snapshot() {
    this.push("nfo", `UA: ${navigator.userAgent.slice(0, 120)}`)
    this.push("nfo", `html.class: "${document.documentElement.className}"`)
    this.push("nfo", `url: ${location.pathname}${location.search}`)
    try {
      const hist = window.Turbo?.session?.history
      this.push("nfo", `Turbo: ${!!window.Turbo} idx=${hist?.currentIndex} len=${hist?.entries?.length}`)
    } catch (e) { this.push("err", `Turbo probe: ${e.message}`) }
    const bridge = window.webkit?.messageHandlers
    this.push("nfo", `bridge: ${bridge ? Object.keys(bridge).join(",") : "none"}`)
  }

  logClick(e) {
    const link = e.target.closest("a,button,[data-action]")
    const tag = link?.tagName?.toLowerCase() || e.target.tagName?.toLowerCase()
    const href = link?.getAttribute?.("href") || ""
    const act = link?.getAttribute?.("data-action") || ""
    const txt = (link?.innerText || link?.textContent || "").trim().slice(0, 40).replace(/\s+/g, " ")
    this.push("clk", `<${tag}> "${txt}" href=${href} act=${act} def=${e.defaultPrevented}`)
  }

  logTurbo(e) {
    const d = e.detail || {}
    const url = d.url?.href || d.url || d.fetchResponse?.response?.url || d.response?.url || ""
    const cls = e.type.includes("error") || e.type.includes("missing") ? "err" : "trb"
    this.push(cls, `${e.type} ${url}`)
  }

  wrapBridge() {
    const mh = window.webkit?.messageHandlers
    if (!mh) return
    this.originalPostMessages = []
    Object.keys(mh).forEach(name => {
      const handler = mh[name]
      if (!handler || typeof handler.postMessage !== "function") return
      const original = handler.postMessage.bind(handler)
      this.originalPostMessages.push({ handler, original })
      handler.postMessage = (payload) => {
        try { this.push("brg", `→${name}: ${JSON.stringify(payload).slice(0, 160)}`) }
        catch { this.push("brg", `→${name}: [unserializable]`) }
        return original(payload)
      }
    })
  }

  unwrapBridge() {
    this.originalPostMessages?.forEach(({ handler, original }) => {
      handler.postMessage = original
    })
  }

  push(cls, msg) {
    const ts = new Date().toISOString().slice(11, 23)
    const line = `${ts} ${msg}`
    this.lines.push(line)
    if (this.lines.length > MAX_LINES) this.lines.shift()
    if (!this.logEl) return
    const row = document.createElement("div")
    row.className = cls
    row.textContent = line
    this.logEl.appendChild(row)
    while (this.logEl.children.length > MAX_LINES) this.logEl.firstChild.remove()
    this.logEl.scrollTop = this.logEl.scrollHeight
  }

  async copy() {
    const text = this.lines.join("\n")
    try {
      await navigator.clipboard.writeText(text)
      this.push("nfo", "copied to clipboard")
    } catch {
      const ta = document.createElement("textarea")
      ta.value = text
      document.body.appendChild(ta)
      ta.select()
      try { document.execCommand("copy"); this.push("nfo", "copied (fallback)") }
      catch (e) { this.push("err", `copy failed: ${e.message}`) }
      ta.remove()
    }
  }
}
