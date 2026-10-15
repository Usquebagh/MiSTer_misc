# MiSTer_misc

A personal custom database for [MiSTer Downloader](https://github.com/MiSTer-devel/Downloader_MiSTer) / `update_all`, holding an odd collection of arcade MRAs and cores that none of the usual databases carry: WIP cores, test builds, community MRAs and alternative sets.

Everything lands in its own folder so it never clashes with files from other databases:

| Repo path | Installed to |
|---|---|
| `_Arcade/_misc/*.mra` | `_Arcade/_misc/` (shows as a **misc** folder in the Arcade menu) |
| `_Arcade/cores/*.rbf` | `_Arcade/cores/` |

## Adding this database to a MiSTer

Easiest: download `downloader_Usquebagh_MiSTer_misc.zip` from the [`db` branch](https://github.com/Usquebagh/MiSTer_misc/tree/db), extract the `.ini` to the root of the SD card, then run `update_all` (or `downloader`).

Or add this to `downloader.ini` by hand:

```ini
[Usquebagh/MiSTer_misc]
db_url = https://raw.githubusercontent.com/Usquebagh/MiSTer_misc/db/db.json.zip
```

ROMs are not included. The MRAs expect the usual MAME ROM zips in `games/mame/`.

## Updating

Commit to `main` and push. A GitHub Action rebuilds `db.json.zip` on the `db` branch within a few minutes.

- New core build: add `Name_YYYYMMDD.rbf` and delete the old one. Downloader removes the old file from the SD card on the next update.
- Don't commit files that another database already ships at the same path.
- Files must be under 100 MB. Don't use Git LFS.

## Licences

Cores and MRAs belong to their respective authors and are under their own licences. This repo only collects them for distribution through Downloader.

Built from [theypsilon/DB-Template_MiSTer](https://github.com/theypsilon/DB-Template_MiSTer).
