import QtQuick

QtObject {
    readonly property color red: "#e3001b"
    readonly property color redDeep: "#8c0010"
    readonly property color black: "#050505"
    readonly property color ink: "#0d0d0d"
    readonly property color white: "#f7f4ec"
    readonly property color grey: "#9a9590"

    property FontLoader displayLoader: FontLoader { source: "fonts/Anton-Regular.ttf" }
    property FontLoader bodyLoader: FontLoader { source: "fonts/BarlowCondensed-Medium.ttf" }
    property FontLoader boldLoader: FontLoader { source: "fonts/BarlowCondensed-Bold.ttf" }
    property FontLoader slashLoader: FontLoader { source: "fonts/BarlowCondensed-BlackItalic.ttf" }
    readonly property string display: displayLoader.status === FontLoader.Ready ? displayLoader.name : "Impact"
    readonly property string body: bodyLoader.status === FontLoader.Ready ? bodyLoader.name : "Arial Narrow"
    readonly property string bold: boldLoader.status === FontLoader.Ready ? boldLoader.name : "Arial Narrow"
    readonly property string slash: slashLoader.status === FontLoader.Ready ? slashLoader.name : "Arial Narrow"

    readonly property var strings: ({
        "systems": ["SYSTEMS", "SISTEMAS"],
        "games": ["GAMES", "JUEGOS"],
        "game": ["GAME", "JUEGO"],
        "year": ["YEAR", "AÑO"],
        "maker": ["MAKER", "FABRICANTE"],
        "type": ["TYPE", "TIPO"],
        "console": ["CONSOLE", "CONSOLA"],
        "handheld": ["HANDHELD", "PORTÁTIL"],
        "arcade": ["ARCADE", "ARCADE"],
        "computer": ["COMPUTER", "ORDENADOR"],
        "collection": ["COLLECTION", "COLECCIÓN"],
        "genre": ["GENRE", "GÉNERO"],
        "developer": ["DEVELOPER", "DESARROLLO"],
        "lastPlayed": ["LAST PLAYED", "ÚLTIMA VEZ"],
        "never": ["NEVER", "NUNCA"],
        "unknown": ["???", "???"],
        "plays": ["PLAYS", "PARTIDAS"],
        "open": ["OPEN", "ENTRAR"],
        "play": ["PLAY", "JUGAR"],
        "random": ["RANDOM", "AL AZAR"],
        "favorite": ["FAVORITE", "FAVORITO"],
        "unfavorite": ["UNFAVORITE", "QUITAR FAV"],
        "system": ["SYSTEM", "SISTEMA"],
        "back": ["BACK", "VOLVER"],
        "menu": ["MENU", "MENÚ"],
        "noGames": ["NO GAMES HERE", "AQUÍ NO HAY JUEGOS"],
        "noDescription": ["No intel on this one yet. Go find out yourself.", "Todavía no hay datos. Descúbrelo tú mismo."],
        "fav": ["FAV", "FAV"],
        "letsGo": ["LET'S GO!", "¡VAMOS!"],
        "takeOver": ["TAKE OVER", "A POR ELLOS"]
    })

    function t(key) {
        var entry = strings[key]
        if (!entry)
            return key
        return Rift.settings.language === "es" ? entry[1] : entry[0]
    }

    function hash(text, salt) {
        var h = 2166136261 ^ (salt || 0)
        var s = String(text || "")
        for (var i = 0; i < s.length; i++) {
            h ^= s.charCodeAt(i)
            h = Math.imul(h, 16777619)
        }
        h ^= h >>> 13
        h = Math.imul(h, 1274126177)
        h ^= h >>> 16
        return (h >>> 0) / 4294967296
    }

    function pad(n, width) {
        var s = String(Math.max(0, n))
        while (s.length < width)
            s = "0" + s
        return s
    }
}
