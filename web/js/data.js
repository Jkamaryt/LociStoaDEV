/* LociStoa data loader: reads the CSV files in the data folder.
 *
 * Each CSV becomes a list of rows, and each row is an object keyed by the column
 * names in the first line. Example: tables.people[0].name
 *
 * If the files cannot be fetched (this happens when index.html is opened by
 * double-clicking it instead of through a web server), it falls back to
 * data/data.bundle.js, an offline copy made by tools/build_data.py.
 */
"use strict";

const DataLoader = (() => {
  const TABLES = ["people", "departments", "offices", "student_orgs", "learning_centers",
    "subjects", "buildings", "campus_lingo", "emergency_numbers", "quick_links", "schools"];

  // Read CSV text into rows. Handles quoted cells, commas and line breaks inside quotes.
  function parseCSV(text) {
    if (text.charCodeAt(0) === 0xfeff) text = text.slice(1);   // marker Excel adds at the start
    const rows = [];
    let row = [], cell = "", quoted = false;
    for (let i = 0; i < text.length; i++) {
      const ch = text[i];
      if (quoted) {
        if (ch === '"' && text[i + 1] === '"') { cell += '"'; i++; }
        else if (ch === '"') quoted = false;
        else cell += ch;
      } else if (ch === '"') quoted = true;
      else if (ch === ",") { row.push(cell); cell = ""; }
      else if (ch === "\n" || ch === "\r") {
        if (ch === "\r" && text[i + 1] === "\n") i++;
        row.push(cell); cell = "";
        if (row.length > 1 || row[0] !== "") rows.push(row);
        row = [];
      } else cell += ch;
    }
    if (cell !== "" || row.length) { row.push(cell); rows.push(row); }
    const header = rows.shift().map((h) => h.trim());
    return rows.map((r) => {
      const item = {};
      header.forEach((h, i) => { item[h] = r[i] === undefined ? "" : r[i]; });
      return item;
    });
  }

  async function fetchText(path) {
    const res = await fetch(path, { cache: "no-store" });
    if (!res.ok) throw new Error(path + " " + res.status);
    return res.text();
  }

  function loadScript(path) {
    return new Promise((resolve, reject) => {
      const s = document.createElement("script");
      s.src = path; s.onload = resolve; s.onerror = () => reject(new Error("Could not load " + path));
      document.head.appendChild(s);
    });
  }

  // The org logos are one big image. Loading it this way works on every host.
  async function loadLogoSheet() {
    try {
      const res = await fetch("assets/org-logos.webp");
      if (!res.ok) return;
      const url = URL.createObjectURL(await res.blob());
      document.documentElement.style.setProperty("--org-logos", "url(" + url + ")");
    } catch (e) { /* the stylesheet's own link to the image is used instead */ }
  }

  async function load() {
    try {
      const texts = await Promise.all(TABLES.map((t) => fetchText("data/" + t + ".csv")));
      const tables = {};
      TABLES.forEach((t, i) => { tables[t] = parseCSV(texts[i]); });
      const logos = JSON.parse(await fetchText("assets/org-logos.json"));
      loadLogoSheet();
      return { tables, logos, source: "csv" };
    } catch (e) {
      await loadScript("data/data.bundle.js");
      return Object.assign({ source: "bundle" }, window.LOCISTOA_BUNDLE);
    }
  }

  return { load, parseCSV };
})();
