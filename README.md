# docker-dijnet-bot

Docker image ami a [dijnet-bot](https://github.com/juzraai/dijnet-bot) alkalmazást futtatja időzítve a cronnal, beépítve a [healthchecks.io](https://healthchecks.io) monitorozóját.

A Díjnet Bot lementi az összes Díjnet-en tárolt számládat, így azok immáron még egy helyen, Nálad is meglesznek.

## Usage

### Perform sync in a daily basis

Az alábbi környezeti változókkal tudod befolyásolni a dijnet-bot alkalmazás működését:

* `DIJNET_USER` A Dijnet felhasználó neve, akihez tartozó számlákat le akarod szinkronizálni.
* `DIJNET_PASS` A Dijnet felhasználó jelszava, akihez tartozó számlákat le akarod szinkronizálni.
* `SLEEP` Késleltetés a Díjnetnek küldött kérések előtt (másodpercben)
* `SYNC_ON_STARTUP` Ha azt szeretnéd, hogy indítás után automatikusan lefusson a szinkronizáció - ne csak ütemezetten a cron segítségével, akkor adj értéket ennek a változónak (bármit).
* `CRON` crontab ütemezés beállítása. Például `0 0 * * *`, hogy minden éjfélkor lefusson a szinkronizálás. Támogatottak a következő shortcut-ok is: `@yearly` `@monthly` `@weekly` `@daily` `@hourly`
* `CRON_ABORT`
* `HEALTHCHECKS_IO_URL` [healthchecks.io](https://healthchecks.io) url or similar cron monitoring to perform a `GET` after a successful sync
* `LOG_MODE` Naplózás módja:
  * default = terminálban könnyen érthető folyamatjelző, fájlba irányítva bővített napló
  * verbose = bővített napló, minden műveletről tájékoztat
  * quiet = nincs kimenet
* `LOG_ROTATE` Állítsd be ezt a változót, hogy a paraméterül megadott napnál régebbi logok automatikusan törölve legyenek a /var/log/dijnet könyvtárból
* `TZ` Beállítja a [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) amit a cron és a logformátumoknál használunk.
* `PUID` beállítja a felhasználó azonosítóját, akinek a nevében fusson az alkalmazás
* `PGID` beállítja a felhasználó csoport azonosítóját, akinek a nevében fusson az alkalmazás

```bash
$ docker run --rm -it -v $(pwd)/config:/etc/dijnet -v /path/to/destination:/data -e DIJNET_USER="<username>" -e DIJNET_PASS="<password>" -e TZ="Europe/Budapest" -e LOG_MODE="default" -e LOG_ROTATE=1 -e CRON="0 0 * * *" -e CRON_ABORT="0 6 * * *" -e SYNC_ON_STARTUP=1 -e HEALTHCHECKS_IO_URL=https://hchk.io/hchk_uuid l4t3b0/dijnet-bot
```
## Changelog

+ **2020. november 01.**
  * Initial release

<br />
<br />
