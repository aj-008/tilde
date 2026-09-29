function score(query, target) {
    if (!query) return 0
    const q = query.toLowerCase()
    const t = target.toLowerCase()

    let qi = 0
    let s = 0
    let prevMatched = false
    let prevWasBoundary = true

    for (let ti = 0; ti < t.length && qi < q.length; ti++) {
        if (t[ti] === q[qi]) {
            s += 1
            if (prevMatched) s += 3          // consecutive-match bonus
            if (prevWasBoundary) s += 5       // start-of-word bonus
            qi++
            prevMatched = true
        } else {
            prevMatched = false
        }
        prevWasBoundary = (t[ti] === " " || t[ti] === "-" || t[ti] === "_" || t[ti] === "/")
    }

    return qi === q.length ? s : -1
}

function filterSort(items, query, getText) {
    if (!query) return items
    const scored = []
    for (const item of items) {
        const sc = score(query, getText(item))
        if (sc >= 0) scored.push([sc, item])
    }
    scored.sort((a, b) => b[0] - a[0])
    return scored.map(([, item]) => item)
}
