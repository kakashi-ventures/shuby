// Focus trap + background-inert helpers shared by every modal-like surface
// in Shuby (bottom-sheet, measurement overlay, questionnaire overlay, etc.).
//
// Why a plain ES module instead of a Stimulus mixin / base class: per
// `.claude/rules/bottom-sheet-overlays.md`, importmap-resolved Stimulus
// static metadata does not propagate to subclasses — every overlay
// controller must implement its own open/close contract. The helpers below
// keep the contract honest by handling the load-bearing a11y pieces in
// exactly one place.
//
// WCAG 2.1 AA criteria addressed:
// - 2.1.2 No Keyboard Trap (inverse — we DELIBERATELY cycle Tab/Shift+Tab
//   inside the modal, but Escape always exits)
// - 2.4.3 Focus Order (move focus into the modal on open, restore on close)
// - 4.1.2 Name, Role, Value (background made inert so screen readers don't
//   wander into hidden content)

const FOCUSABLE_SELECTOR = [
  "a[href]:not([disabled])",
  "button:not([disabled])",
  'input:not([disabled]):not([type="hidden"])',
  "select:not([disabled])",
  "textarea:not([disabled])",
  '[tabindex]:not([tabindex="-1"]):not([disabled])'
].join(",")

function isVisible(el) {
  if (el.closest('[aria-hidden="true"]')) return false
  if (el.closest("[inert]")) return false
  return el.offsetParent !== null || el === document.activeElement
}

function focusableWithin(container) {
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter(isVisible)
}

// Activates a Tab/Shift+Tab cycle within `container` and moves focus
// into it. Returns a teardown function that restores focus to whoever
// had it before activation.
export function activateFocusTrap(container) {
  const previouslyFocused = document.activeElement instanceof HTMLElement ? document.activeElement : null

  const onKeydown = (event) => {
    if (event.key !== "Tab") return
    const focusable = focusableWithin(container)
    if (focusable.length === 0) {
      event.preventDefault()
      container.focus()
      return
    }
    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    const active = document.activeElement
    if (event.shiftKey) {
      if (active === first || !container.contains(active)) {
        event.preventDefault()
        last.focus()
      }
    } else if (active === last) {
      event.preventDefault()
      first.focus()
    }
  }
  container.addEventListener("keydown", onKeydown)

  const initial = focusableWithin(container)[0]
  if (initial) {
    initial.focus()
  } else if (container.tabIndex >= 0 || container.hasAttribute("tabindex")) {
    container.focus()
  }

  return function deactivate() {
    container.removeEventListener("keydown", onKeydown)
    if (previouslyFocused && document.body.contains(previouslyFocused)) {
      previouslyFocused.focus()
    }
  }
}

// Marks every direct child of <body> that does NOT contain `host` as
// `inert`, hiding it from focus + the accessibility tree while the
// overlay is open. Returns a teardown function that restores the
// previous state — only attributes WE added are removed, so any pre-
// existing `inert` (e.g. from another overlay layered above) survives.
export function setBackgroundInert(host) {
  if (!("inert" in HTMLElement.prototype)) {
    return function noop() {}
  }
  const touched = []
  for (const child of Array.from(document.body.children)) {
    if (child === host || child.contains(host)) continue
    if (child.tagName === "SCRIPT" || child.tagName === "STYLE") continue
    if (child.hasAttribute("inert")) continue
    child.setAttribute("inert", "")
    child.dataset.shubyOverlayInert = "true"
    touched.push(child)
  }
  return function restore() {
    for (const el of touched) {
      if (el.dataset.shubyOverlayInert === "true") {
        el.removeAttribute("inert")
        delete el.dataset.shubyOverlayInert
      }
    }
  }
}
