cfg = {}

-- scegliere se aggiornare la vita ogni "minuti", "secondi", "millisecondi"
-- ATTENZIONE più veloce sarà il clock, più aggiornamenti il server dovrà
-- fare, questo potrebbe portare a lag del server se troppo veloci!
cfg.updateCheckType = "secondi"
cfg.updateCheck = 5
-- per quanti secondi lo script deve controllare l'hash del Giocatore
-- nel momento del login? (Consigliato: 50-100)
cfg.secondsCheck = 80

-- coordinate dello spawnpoint
cfg.spawnPoint = {
    x = 283.47348022461,
    y = -578.79577636719,
    z = 43.212776184082,
    heading = 70
}

-- se controllare gli item e rimuoverli alla morte
cfg.pulisciInventario = false
cfg.pulisciSoldi = false
cfg.pulisciArmi = false

cfg.hashesList = {
    "1885233650", -- modello del mascio
    "-1667301416" -- modello della donna
}
