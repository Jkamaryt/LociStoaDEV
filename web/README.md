# LociStoa web prototype

A clickable browser version of the LociStoa design. It is separate from the SwiftUI app in `LociStoa/` and exists so the team can try design changes quickly on any computer.

## Run it

- **Quickest:** double-click `index.html`. It opens with the offline data copy in `data/data.bundle.js`.
- **With live data:** double-click `start-demo.bat` (needs Python), or run `python -m http.server 8000` in this folder and open http://localhost:8000. This reads the CSV files directly, so edits to them show up on reload.

## What is in here

| Path | What it is |
|---|---|
| `index.html` | Every screen, written as one template |
| `css/styles.css` | The page frame, school color themes, dark mode |
| `js/app.js` | The app's state and logic |
| `js/data.js` | Reads the CSV files |
| `js/engine.js` | Small template engine that redraws the page |
| `data/*.csv` | The content: people, offices, orgs, learning centers, buildings, schools |
| `data/data.bundle.js` | Offline copy of the CSVs, used when the page is opened by double-click |

## Sign-in is a stand-in

The sign-in screen only checks the email's domain against `data/schools.csv` to pick the school and its colors. It does not contact Google or Microsoft and never asks for a password. Real sign-in needs a backend.

`data/data.bundle.js` is a snapshot. If you change a CSV, the double-click version will not show it until the bundle is rebuilt; use the local server instead.
