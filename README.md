# oma.metal

Spela metalströmmen från [khz.se](https://wr03-ice.stream.khz.se/wr03_mp3) med ett klick i Omarchy-baren.

- **Klick** på rock-handen: strömmen startar och ikonen blir **röd**.
- **Klick igen**: strömmen stoppas och ikonen blir **vit**.

## Installation

```bash
omarchy plugin add https://github.com/nmlit/oma.metal.git --enable
omarchy-restart-shell
```

Flytta vid behov widgeten:

```bash
omarchy bar move oma.metal --section right
```

Uppdatera:

```bash
omarchy plugin update oma.metal --yes
omarchy-restart-shell
```

## Krav

- `mpv` (används i första hand, med `--no-video`). Saknas den används `ffplay` eller `mpg123`.
- systemd-användarsession (`systemd-run --user`), som i en vanlig Omarchy-installation.

## Så fungerar det

Spelaren startas av `metal.sh` som en egen systemd-användarenhet, `oma-metal.service`.
Den lever alltså inte som barnprocess till omarchy-shell:

- Vid `omarchy-restart-shell` fortsätter musiken, och ikonen synkas direkt till rött
  eftersom pluginet frågar enheten om läget (var tredje sekund och vid start).
- Det blir aldrig någon föräldralös spelare: stopp gör `systemctl --user stop oma-metal`,
  som avslutar hela enhetens processgrupp.
- Dör strömmen av sig själv (t.ex. nätverksfel) blir ikonen vit igen.

Pluginet skriver aldrig i sin egen mapp. Spelarens PID sparas i
`~/.local/state/oma.metal/pid` medan strömmen spelar och tas bort vid stopp.

## Kommandon

```bash
omarchy-shell -q oma.metal toggle   # start/stopp
omarchy-shell -q oma.metal play
omarchy-shell -q oma.metal stop

~/.config/omarchy/plugins/oma.metal/metal.sh status   # playing | stopped
systemctl --user status oma-metal                     # spelarens enhet
```

En annan ström kan väljas med miljövariabeln `OMA_METAL_URL` i omarchy-shells miljö.

## Ikon

`icon-white.png` och `icon-red.png` skapas från en vit, transparent käll-PNG:

```bash
python3 tools/make-icons.py rockhand.png
```

## Licens

MIT
