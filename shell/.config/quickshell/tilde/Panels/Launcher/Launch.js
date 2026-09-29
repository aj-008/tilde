.pragma library
// Extension -> handler routing. Edit these lists to taste.
const NVIM_EXTS = new Set([
    "md", "txt", "conf", "cfg", "py", "rs", "c", "cpp", "h", "hpp",
    "toml", "json", "yaml", "yml", "sh", "fish", "lua", "qml", "js",
    "ts", "html", "css", "rasi", "service", "nix", "vim", "env", "gitconfig"
])

const ZATHURA_EXTS = new Set([
    "pdf", "epub", "djvu", "cbz", "cbr", "ps"
])

const TERMINAL = "foot"   // your terminal
const EDITOR = "nvim"
const READER = "zathura"
const BROWSER = "qutebrowser"

function extOf(path) {
    const base = path.split("/").pop()
    const dot = base.lastIndexOf(".")
    return dot > 0 ? base.slice(dot + 1).toLowerCase() : ""
}

function fishQuote(str) {
    return "'" + str.replace(/\\/g, "\\\\").replace(/'/g, "\\'") + "'"
}

function nvimThenCdScript(path) {
    const q = fishQuote(path)
    return `nvim ${q}; cd (dirname ${q}); exec fish`
}

// Pure: given a result item, return { argv } to spawn, or { clipboard } to
// copy text instead of exec'ing. No side effects here — actual process
// spawning happens in QML (ResultModel.qml) via a real Process object,
// since plain .js modules don't reliably inherit the QML import context
// needed for things like Quickshell.execDetached.
function resolve(item) {
    switch (item.type) {
        case "app": {
            const app = item.payload
            return { argv: app.terminal ? [TERMINAL, "-e", ...app.exec] : app.exec }
        }
        case "file": {
            const ext = extOf(item.payload)
            if (ZATHURA_EXTS.has(ext)) {
                return { argv: [READER, item.payload] }
            }
            return { argv: [TERMINAL, "-e", "fish", "-c", nvimThenCdScript(item.payload)] }
        }
        case "bookmark":
            return { argv: [BROWSER, item.payload.url] }
        case "websearch":
            return { argv: [BROWSER, item.payload] }
        case "calc":
            return { clipboard: item.payload }
        default:
            console.warn("launcher: unknown result type", item.type)
            return null
    }
}

const IMAGE_EXTS = new Set(["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp"])
const ARCHIVE_EXTS = new Set(["zip", "tar", "gz", "xz", "7z", "rar"])

function iconNameFor(item) {
    switch (item.type) {
        case "app":
            return item.payload.icon || "application-x-executable"
        case "file": {
            const ext = extOf(item.payload)
            if (ext === "pdf") return "application-pdf"
            if (ZATHURA_EXTS.has(ext)) return "x-office-document"
            if (IMAGE_EXTS.has(ext)) return "image-x-generic"
            if (ARCHIVE_EXTS.has(ext)) return "package-x-generic"
            return "text-x-generic"
        }
        case "bookmark":
            return "qutebrowser"
        case "websearch":
            return "edit-find"
        case "calc":
            return "accessories-calculator"
        default:
            return ""
    }
}
