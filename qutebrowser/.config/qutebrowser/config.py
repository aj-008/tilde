import json
from pathlib import Path

config.load_autoconfig(False)

# ============================================================
# KEYBINDS — Colemak-DH navigation remap
# ============================================================
for key in ['h', 'j', 'k', 'l', 'H', 'J', 'K', 'L']:
    try:
        config.unbind(key)
    except Exception:
        pass  # not bound by default, ignore

# --- normal mode: scrolling ---
# n/e are homerow-modded, so holding them down doesn't repeat like a normal
# key would — each press needs to move further on its own instead.
config.bind('m', 'scroll-px -200 0')
config.bind('n', 'scroll-px 0 200')
config.bind('e', 'scroll-px 0 -200')
config.bind('i', 'scroll-px 200 0')

# --- normal mode: history / tabs (shifted versions) ---
config.bind('M', 'back')
config.bind('I', 'forward')
config.bind('N', 'tab-prev')
config.bind('E', 'tab-next')

# --- search: next/prev match on l / L (nvim-style muscle memory) ---
# 'l' is unused after the hjkl unbind above, so it's free.
config.bind('l', 'search-next')
config.bind('L', 'search-prev')

config.bind(',qa', 'set-cmd-text :quickmark-add {url} ')
config.bind(',ba', 'bookmark-add')

# --- insert mode: 'i' got clobbered by the scroll-right remap above,
#     so it lives on 'k' instead ---
config.bind('k', 'mode-enter insert')

# --- caret mode uses hjkl for char/line movement too ---
config.bind('m', 'move-to-prev-char', mode='caret')
config.bind('n', 'move-to-next-line', mode='caret')
config.bind('e', 'move-to-prev-line', mode='caret')
config.bind('i', 'move-to-next-char', mode='caret')
config.bind('M', 'move-to-start-of-prev-block', mode='caret')
config.bind('I', 'move-to-start-of-next-block', mode='caret')

# --- hint-mode chars: your Colemak-DH home row instead of qwerty's asdfghjkl ---
c.hints.chars = 'arstgmneio'

# ============================================================
# KEYBINDS — Tab switching (Ctrl instead of Alt)
# ============================================================
for i in range(1, 10):
    config.bind(f'<Ctrl+{i}>', f'tab-focus {i}')
config.bind('<Ctrl+0>', 'tab-focus -1')

# ============================================================
# SEARCH ENGINES
# ============================================================
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'w': 'https://en.wikipedia.org/wiki/Special:Search?search={}',
}

c.url.start_pages = ['https://www.google.com']
c.url.default_page = 'https://www.google.com'
# ============================================================
# APPEARANCE — fonts
# ============================================================
# UI chrome (tabs, statusbar, completion menu, hints) stays monospace —
# this is the "tty" look and it's fine there.
c.fonts.default_family = 'JetBrainsMono Nerd Font'
c.fonts.default_size = '11pt'

# Web page rendering gets Inter instead of the browser's stock sans/serif.
# Falls back through the list if Inter isn't installed.
c.fonts.web.family.standard = 'Inter, "Segoe UI", sans-serif'
c.fonts.web.family.sans_serif = 'Inter, "Segoe UI", sans-serif'
c.fonts.web.family.serif = 'Inter, serif'   # comment out to keep real serif fonts on serif sites
c.fonts.web.size.default = 16
c.fonts.web.size.default_fixed = 13         # code blocks / <pre> stay monospace-sized


config.bind('<z><l>', 'spawn --userscript qute-pass')
config.bind('<z><u><l>', 'spawn --userscript qute-pass --username-only')
config.bind('<z><p><l>', 'spawn --userscript qute-pass --password-only')
config.bind('<z><o><l>', 'spawn --userscript qute-pass --otp-only')

# ============================================================
# APPEARANCE — matugen integration
# ============================================================
matugen_colors_path = Path.home() / '.cache' / 'matugen' / 'qutebrowser-colors.json'

if matugen_colors_path.exists():
    with open(matugen_colors_path) as f:
        m = json.load(f)

    bg = m['background']
    fg = m['foreground']
    primary = m['primary']
    on_primary = m['on_primary']
    secondary = m.get('secondary', primary)
    tertiary = m.get('tertiary', secondary)
    error = m.get('error', '#ff5555')
    surface = m.get('surface', bg)
    outline = m.get('outline', fg)

    # Statusbar
    c.colors.statusbar.normal.bg = bg
    c.colors.statusbar.normal.fg = fg
    c.colors.statusbar.command.bg = bg
    c.colors.statusbar.command.fg = fg
    c.colors.statusbar.insert.bg = primary
    c.colors.statusbar.insert.fg = on_primary
    c.colors.statusbar.caret.bg = secondary
    c.colors.statusbar.caret.fg = bg
    c.colors.statusbar.url.fg = fg
    c.colors.statusbar.url.success.http.fg = secondary
    c.colors.statusbar.url.success.https.fg = secondary
    c.colors.statusbar.url.warn.fg = tertiary
    c.colors.statusbar.url.error.fg = error

    # Tabs
    c.colors.tabs.bar.bg = bg
    c.colors.tabs.odd.bg = surface
    c.colors.tabs.even.bg = surface
    c.colors.tabs.odd.fg = fg
    c.colors.tabs.even.fg = fg
    c.colors.tabs.selected.odd.bg = primary
    c.colors.tabs.selected.even.bg = primary
    c.colors.tabs.selected.odd.fg = on_primary
    c.colors.tabs.selected.even.fg = on_primary
    c.colors.tabs.indicator.start = primary
    c.colors.tabs.indicator.stop = tertiary

    # Completion widget
    c.colors.completion.fg = fg
    c.colors.completion.odd.bg = bg
    c.colors.completion.even.bg = surface
    c.colors.completion.category.bg = bg
    c.colors.completion.category.fg = primary
    c.colors.completion.item.selected.bg = primary
    c.colors.completion.item.selected.fg = on_primary
    c.colors.completion.match.fg = tertiary

    # Downloads bar
    c.colors.downloads.bar.bg = bg
    c.colors.downloads.start.bg = primary
    c.colors.downloads.start.fg = on_primary

    # Hints
    c.colors.hints.bg = primary
    c.colors.hints.fg = on_primary
    c.colors.hints.match.fg = tertiary

    c.colors.webpage.bg = bg
    c.colors.webpage.preferred_color_scheme = 'dark'
else:
    c.colors.webpage.preferred_color_scheme = 'dark'

# ============================================================
# APPEARANCE — layout / chrome
# ============================================================
c.tabs.position = 'top'
c.tabs.show = 'always'
c.tabs.title.format = '{index}: {current_title}'
c.tabs.favicons.scale = 1.0
c.tabs.padding = {'top': 4, 'bottom': 4, 'left': 6, 'right': 6}
c.tabs.indicator.width = 2

c.statusbar.show = 'always'
c.statusbar.padding = {'top': 2, 'bottom': 2, 'left': 4, 'right': 4}

c.downloads.position = 'bottom'

c.window.transparent = False

# ============================================================
# BEHAVIOR
# ============================================================
c.auto_save.session = True
c.tabs.last_close = 'close'
c.new_instance_open_target = 'tab'
c.scrolling.smooth = True

# Choppy scrolling in qutebrowser is almost always GPU rasterization/
# compositing falling back to software rather than anything qutebrowser
# itself controls — these flags get passed straight to the underlying
# Chromium engine.
c.qt.args = [
    'enable-gpu-rasterization',
    'enable-zero-copy',
    'ignore-gpu-blocklist',
    'num-raster-threads=4',
]
c.content.autoplay = False
c.content.blocking.enabled = True
