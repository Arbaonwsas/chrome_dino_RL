# Vendored game page

The `game/` directory is a verbatim copy of [wayou/t-rex-runner][1], the
open-source Chrome dino game that exposes the `Runner` JavaScript API this
project drives (`Runner.instance_`, `Runner.config.ACCELERATION`,
`distanceMeter.digits`, `crashed`, `playing`, `restart()`, `stop()`, `play()`).

- Source: https://github.com/wayou/t-rex-runner
- Commit: `5455bfa408ec6b707c7300ff194b7390733a766d` (2022-06-08)
- License: BSD 3-Clause — see [LICENSE](LICENSE), retained as required

## Why it is vendored

The URL this project originally pointed at is dead:

    http://www.aboutsamyuen.com/projects/chrome_dino_js/index.html   # no longer resolves

The whole environment depended on that single third-party host, so the project
could not run at all once the domain went away. Serving the page from the
repository removes that external dependency.

`run.sh` serves this directory on `http://127.0.0.1:8765/` and `config1.py`
points `game_url` there. Use `PORT` / `GAME_DIR` to change either side; the two
must agree.

[1]: https://github.com/wayou/t-rex-runner
