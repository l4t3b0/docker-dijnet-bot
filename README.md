# docker-dijnet-bot

Docker image ami a [dijnet-bot](https://github.com/juzraai/dijnet-bot) alkalmazást futtatja időzítve a cronnal, beépítve a [healthchecks.io](https://healthchecks.io) monitorozóját.

A Díjnet Bot lementi az összes Díjnet-en tárolt számládat, így azok immáron még egy helyen, Nálad is meglesznek.

## Usage

### Configure rclone

rclone needs a configuration file where credentials to access different storage
provider are kept.

By default, this image uses a file `/etc/rclone.conf` and a mounted volume may be used to keep that information persisted.

A first run of the container can help in the creation of the file, but feel free to manually create one.

```
$ mkdir config
$ docker run --rm -it -v $(pwd)/config:/etc/rclone l4t3b0/rclone
```

### Perform sync in a daily basis

A few environment variables allow you to customize the behavior of rclone:

* `DIJNET_USER` A Dijnet felhasználó neve, akihez tartozó számlá
* `DIJNET_PASS` destination location for `rclone sync/copy/move` command. Directories with spaces should be wrapped in single quotes.
* `SLEEP` Késleltetés a Díjnetnek küldött kérések előtt (másodpercben)
* `SYNC_ON_STARTUP` Ha azt szeretnéd, hogy indítás után automatikusan lefusson a szinkronizáció - ne csak ütemezetten a cron segítségével, akkor adj értéket ennek a változónak (bármit).
* `CRON` crontab ütemezés beállítása. Például `0 0 * * *`, hogy minden éjfélkor lefusson a szinkronizálás. Támogatottak a következő shortcut-ok is: `@yearly` `@monthly` `@weekly` `@daily` `@hourly`
* `CRON_ABORT` crontab schedule `0 6 * * *` to abort sync at 6am
* `HEALTHCHECKS_IO_URL` [healthchecks.io](https://healthchecks.io) url or similar cron monitoring to perform a `GET` after a successful sync
* `LOG_MODE` Naplózás módja:
  * default = terminálban könnyen érthető folyamatjelző, fájlba irányítva bővített napló
  * verbose = bővített napló, minden műveletről tájékoztat
  * quiet = nincs kimenet
* `LOG_ROTATE` set variable to delete logs older than specified days from /var/log/rclone
* `TZ` set the [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to use for the cron and log `Europe/Budapest`
* `PUID` set variable to specify user to run rclone as.
* `PGID` set variable to specify group to run rclone as.

```bash
$ docker run --rm -it -v $(pwd)/config:/etc/dijnet -v /path/to/destination:/data -e DIJNET_USER="<username>" -e DIJNET_PASS="<password>" -e TZ="Europe/Budapest" -e LOG_MODE="default" -e LOG_ROTATE=1 -e CRON="0 0 * * *" -e CRON_ABORT="0 6 * * *" -e SYNC_ON_STARTUP=1 -e HEALTHCHECKS_IO_URL=https://hchk.io/hchk_uuid l4t3b0/dijnet-bot
```
## Changelog

+ **2020. november 01.**
  * Initial release

<br />
<br />
