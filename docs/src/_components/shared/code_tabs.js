function initCodeTabs(root) {
  if (root.classList.contains("is-enhanced")) return

  const tabs = Array.from(root.querySelectorAll('[role="tab"]'))
  const panels = Array.from(root.querySelectorAll('[role="tabpanel"]'))
  if (tabs.length === 0) return

  root.classList.add("is-enhanced")

  function activate(index, { focus = true } = {}) {
    tabs.forEach((tab, i) => {
      const selected = i === index
      tab.setAttribute("aria-selected", String(selected))
      tab.setAttribute("tabindex", selected ? "0" : "-1")
      panels[i].hidden = !selected
    })
    if (focus) tabs[index].focus()
  }

  tabs.forEach((tab, i) => {
    tab.addEventListener("click", () => activate(i))
    tab.addEventListener("keydown", (event) => {
      let next = null
      switch (event.key) {
        case "ArrowRight":
          next = (i + 1) % tabs.length
          break
        case "ArrowLeft":
          next = (i - 1 + tabs.length) % tabs.length
          break
        case "Home":
          next = 0
          break
        case "End":
          next = tabs.length - 1
          break
        default:
          return
      }
      event.preventDefault()
      activate(next)
    })
  })
}

function initAllCodeTabs() {
  document.querySelectorAll(".code-tabs").forEach(initCodeTabs)
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initAllCodeTabs)
} else {
  initAllCodeTabs()
}
