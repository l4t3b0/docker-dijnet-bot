# docker-dijnet-bot

Docker image ami a [dijnet-bot](https://github.com/juzraai/dijnet-bot) alkalmazást futtatja időzítve a cronnal, beépítve a [healthchecks.io](https://healthchecks.io) monitorozóját.

A Díjnet Bot lementi az összes Díjnet-en tárolt számládat, így azok immáron még egy helyen, Nálad is meglesznek.

## Használat

Az első indítás után, amennyiben nem találja a konfigurációs fájlt, akkor odamásol egy template konfigurációs fájlt és leáll.

Ezután ki kell tölteni minimum a DIJNET_USER és DIJNET_PASS változókat és utána mehet a menet.

### A Docker indításához használtkörnyezeti változók

Az alábbi környezeti változókkal tudod befolyásolni a dijnet-bot alkalmazás működését:

* `EXECUTE_ON_STARTUP` Ha azt szeretnéd, hogy indítás után automatikusan lefusson a szinkronizáció - ne csak ütemezetten a cron segítségével, akkor adj értéket ennek a változónak (bármit).
* `CRON` crontab ütemezés beállítása. Például `0 0 * * *`, hogy minden éjfélkor lefusson a szinkronizálás. Támogatottak a következő shortcut-ok is: `@yearly` `@monthly` `@weekly` `@daily` `@hourly`
* `CRON_ABORT`
* `HEALTHCHECKS_IO_URL` [healthchecks.io](https://healthchecks.io) url ami az alkalmazás sikerességének monitorozását teszi lehetővé
* `TZ` Beállítja a [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) amit a cron és a logformátumoknál használunk.
* `PUID` beállítja a felhasználó azonosítóját, akinek a nevében fusson az alkalmazás
* `PGID` beállítja a felhasználó csoport azonosítóját, akinek a nevében fusson az alkalmazás


### docker cli

```
docker run -d \
  --name=dijnet-bot \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ="Europe/Budapest"
  -e CRON="@weekly"
  -e EXECUTE_ON_STARTUP=1
  -e HEALTHCHECKS_IO_URL=https://hchk.io/hchk_uuid
  -v <path to config>:/etc/dijnet
  -v <path to log>:/var/log/dijnet
  -v <path to data>:/data
  l4t3b0/dijnet-bot
```

### Unraid
Ha ismered és használod az [Unraid](https://unraid.net/) operációs rendszert, akkor szeretném felhívni a figyelmed, hogy van [Unraid docker template](https://github.com/l4t3b0/unraid-docker-templates) ehhez az alkalmazáshoz. 
## Changelog

+ **2020. november 01.**
  * Initial release

<br />
<br />
