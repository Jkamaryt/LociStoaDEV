/* LociStoa web app: the app's logic.
 *
 * How it fits together:
 *   data/*.csv      the content (people, offices, orgs, ...). Edit these to change what the app shows.
 *   js/data.js      reads the CSV files.
 *   js/app.js       THIS FILE: keeps track of what the student is doing (state) and
 *                   works out what every screen should show (view).
 *   index.html      what the screens look like. It fills in the {{ blanks }} with values from view().
 *   js/engine.js    the small engine that connects the two and redraws the page when state changes.
 */
"use strict";

class LociStoaApp extends MiniApp {
  constructor(data) {
    super();
    const T = data.tables;
    const list = (text) =>
      text
        ? text
            .split(";")
            .map((x) => x.trim())
            .filter(Boolean)
        : [];

    // ---- Turn each CSV table into the shape the screens use ----
    // departments.csv
    this.DM = {};
    T.departments.forEach((d) => {
      this.DM[d.name] = [d.category, d.reports_to];
    });
    // subjects.csv
    this.subjects = T.subjects.map((x) => [x.code, x.name]);
    // people.csv
    this.people = T.people.map((p, i) => {
      const parts = p.name
        .replace(/[^A-Za-z .'-]/g, "")
        .split(" ")
        .filter(Boolean);
      return {
        id: i,
        name: p.name,
        role: p.title,
        dept: p.department,
        office: p.office || "Not listed",
        email: p.email,
        level: Number(p.rank_level),
        fac: p.is_faculty === "1",
        initials: ((parts[0] || "?")[0] + (parts.length > 1 ? parts[parts.length - 1][0] : "")).toUpperCase(),
        hay: (p.name + " " + p.title + " " + p.department).toLowerCase(),
      };
    });
    const counts = {};
    this.people.forEach((p) => {
      counts[p.dept] = (counts[p.dept] || 0) + 1;
    });
    this.depts = Object.keys(counts)
      .sort()
      .map((n) => ({ name: n, n: counts[n], hay: n.toLowerCase() }));
    // offices.csv
    this.offices = T.offices.map((f) => {
      const keywords = list(f.keywords);
      return {
        id: f.office_id,
        name: f.name,
        category: f.category,
        goHereFor: f.go_here_for,
        subtitle: f.subtitle,
        keywords: keywords,
        location: f.location,
        hours: f.hours,
        phone: f.phone,
        email: f.email,
        website: f.website,
        note: f.note,
        departments: list(f.departments),
        hay: (f.name + " " + f.go_here_for + " " + keywords.join(" ") + " " + f.category).toLowerCase(),
      };
    });
    // student_orgs.csv (li = the org's position in the logo sheet, -1 if it has no logo)
    const logoOrder = (data.logos && data.logos.order) || [];
    this.orgs = T.student_orgs.map((o, i) => ({
      i: i,
      li: logoOrder.indexOf(o.org_id),
      cat: o.category,
      name: o.name,
      short: o.short_name,
      desc: o.description || "No description listed.",
      email: o.email,
      site: o.website,
      hay: (o.name + " " + o.short_name + " " + o.category).toLowerCase(),
    }));
    this.orgCatNames = [];
    this.orgs.forEach((o) => {
      if (this.orgCatNames.indexOf(o.cat) === -1) this.orgCatNames.push(o.cat);
    });
    this.orgCatNames.sort();
    // learning_centers.csv
    this.centers = T.learning_centers.map((c) => {
      const codes = list(c.subject_codes);
      return {
        id: c.center_id,
        name: c.name,
        cat: c.category,
        subjects: c.subjects_covered,
        building: c.building,
        room: c.room,
        hours: c.hours,
        how: c.how_to_get_help,
        contact: c.contact,
        email: c.email,
        phone: c.phone,
        book: c.booking_url,
        term: c.term,
        url: c.website,
        notes: c.notes,
        codes: codes,
        map: c.map_building_id,
        hay: (c.name + " " + c.subjects_covered + " " + c.building + " " + codes.join(" ") + " tutor tutoring").toLowerCase(),
      };
    });
    // buildings.csv, campus_lingo.csv, emergency_numbers.csv, quick_links.csv
    this.buildings = T.buildings.map((b) => ({
      id: b.building_id,
      short: b.short_name,
      name: b.name,
      layer: b.category,
      x: Number(b.map_x),
      y: Number(b.map_y),
      w: Number(b.map_width),
      h: Number(b.map_height),
      inside: b.whats_inside,
    }));
    this.lingo = T.campus_lingo.map((l) => ({ term: l.term, meaning: l.meaning, b: l.building_id }));
    this.numbers = T.emergency_numbers.map((n) => ({ number: n.number, chip: n.short_label, label: n.description, primary: n.is_primary === "1" }));
    this.links = T.quick_links.map((l) => ({ label: l.label, url: l.url }));
    // schools.csv: which email domain belongs to which school, and which color theme it gets
    const schoolRows = T.schools && T.schools.length ? T.schools : [
      { school_id: "mtu", name: "Michigan Technological University", short_name: "Michigan Tech", email_domain: "mtu.edu", sign_in_provider: "google", theme: "mtu" },
    ];
    this.schools = schoolRows.map((x) => ({ id: x.school_id, name: x.name, short: x.short_name, domain: x.email_domain.toLowerCase(), provider: x.sign_in_provider, theme: x.theme }));
    this.about = {
      source: data.source === "csv" ? "Data loaded live from the CSV files in the data folder." : "Data loaded from the offline copy (data/data.bundle.js).",
      counts:
        this.people.length +
        " people · " +
        this.depts.length +
        " departments · " +
        this.offices.length +
        " offices · " +
        this.orgs.length +
        " student orgs · " +
        this.centers.length +
        " learning centers",
    };

    // ---- What this student has saved in this browser ----
    let saved = {};
    try {
      saved = JSON.parse(localStorage.getItem("locistoa-proto-v3") || "{}") || {};
    } catch (e) {
      saved = {};
    }
    // A saved sign-in only counts if that school is still in schools.csv.
    const userSchool = saved.user ? this.schools.find((sc) => sc.id === saved.user.school) : null;
    const user = userSchool ? saved.user : null;
    let prefersDark = false;
    try {
      prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    } catch (e) {}
    this.state = {
      tab: "home",
      prevTab: "home",
      user: user,                                   // { email, school } or null when signed out
      theme: userSchool ? userSchool.theme : "purple",   // always comes from the school, never picked by hand
      dark: typeof saved.dark === "boolean" ? saved.dark : prefersDark,
      siEmail: "",
      siErr: "",
      widgets: saved.widgets || {},
      calDay: null,
      pv: "dir",
      planMode: "tasks",
      dirQuery: "",
      filter: "All",
      dirLoading: false,
      dept: null,
      deptQuery: "",
      office: null,
      helpQuery: "",
      org: null,
      orgQuery: "",
      center: null,
      tutorQuery: "",
      orgCat: "All",
      sheet: null,
      contactId: null,
      favs: saved.favs || {},
      query: "",
      layer: "All",
      building: null,
      floor: "1F",
      toast: null,
      confirm: null,
      addType: "Assignment",
      addCourse: null,
      cSubj: null,
      cSubjQuery: "",
      cNum: "",
      cDays: {},
      cStart: "10:00",
      cEnd: "10:50",
      cLoc: "",
      cErr: "",
      classes: saved.classes || [],
      tasks: saved.tasks || [],
    };
  }
  onUpdate() {
    if (this.scrollToTop) {
      this.scrollToTop = false;
      const m = document.querySelector("main");
      if (m) m.scrollTop = 0;
    }
    try {
      localStorage.setItem(
        "locistoa-proto-v3",
        JSON.stringify({ classes: this.state.classes, tasks: this.state.tasks, favs: this.state.favs, widgets: this.state.widgets, user: this.state.user, dark: this.state.dark }),
      );
    } catch (e) {}
  }
  // Stand-in for Google or Microsoft sign-in: the email's domain picks the school.
  signIn(typed) {
    const email = String(typed || this.state.siEmail).trim().toLowerCase();
    const parts = email.match(/^[^@\s]+@([^@\s]+\.[^@\s]+)$/);
    if (!parts) {
      this.setState({ siErr: "Enter your full school email, like you@mtu.edu." });
      return;
    }
    const domain = parts[1];
    const school = this.schools.find((sc) => domain === sc.domain || domain.endsWith("." + sc.domain));
    if (!school) {
      const names = this.schools.map((sc) => sc.short).join(", ");
      this.setState({ siErr: "Your school isn't on LociStoa yet. Right now it works with: " + names + "." });
      return;
    }
    this.scrollToTop = true;
    this.setState({ user: { email: email, school: school.id }, theme: school.theme, siEmail: "", siErr: "", tab: "home", sheet: null });
  }
  signOut() {
    this.scrollToTop = true;
    this.setState({ user: null, theme: "purple", tab: "home", sheet: null, siEmail: "", siErr: "" });
  }
  go(tab, extra) {
    const next = Object.assign({ tab: tab, sheet: null }, extra || {});
    if (tab === "people" || tab === "help") {
      const pv = next.pv || this.state.pv;
      const helpish = pv === "help" || pv === "tutor";
      if (next.pv) next.tab = helpish ? "help" : "people";
      else next.pv = tab === "help" ? (helpish ? pv : "help") : helpish ? "dir" : pv;
    }
    if (next.tab === "planner" && this.state.tab !== "planner") next.prevTab = this.state.tab;
    if (next.tab !== this.state.tab) this.scrollToTop = true;
    this.setState(next);
    if (next.tab === "people" && next.pv === "dir") {
      clearTimeout(this.loadTimer);
      this.setState({ dirLoading: true });
      this.loadTimer = setTimeout(() => this.setState({ dirLoading: false }), 600);
    }
  }
  toggleTask(id) {
    let nowDone = false;
    const tasks = this.state.tasks.map((t) => {
      if (t.id !== id) return t;
      nowDone = !t.done;
      return Object.assign({}, t, { done: nowDone });
    });
    this.setState({ tasks: tasks, toast: nowDone ? { text: "Marked done", id: id } : null });
    clearTimeout(this.toastTimer);
    if (nowDone) this.toastTimer = setTimeout(() => this.setState({ toast: null }), 4500);
  }
  view() {
    const s = this.state;
    const accent = "var(--accent)";
    const INK = "var(--ink)";
    const CAP = 40;
    const I = {
      home: "M3 10.5 12 3l9 7.5M5 9.5V21h14V9.5",
      people: "M12.5 8a3.5 3.5 0 1 1-7 0 3.5 3.5 0 0 1 7 0zM2.5 20c.8-3.5 3.4-5.5 6.5-5.5s5.7 2 6.5 5.5M16 4.6a3.5 3.5 0 0 1 0 6.8M18 14.8c1.8.7 3 2.5 3.5 5.2",
      map: "M9 4 3 6v14l6-2 6 2 6-2V4l-6 2-6-2zM9 4v14M15 6v14",
      planner: "M6 3h12a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2zM8 9l1.5 1.5L12 8M8 15h8",
      more: "M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z",
      help: "M9 3h6v5H9zM3 16h6v5H3zM15 16h6v5h-6zM12 8v4M6 16v-4h12v4",
      link: "M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1",
      clock: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0zM12 7v5l3 2",
      phone: "M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z",
      flag: "M5 21V4M5 4h12l-2 4 2 4H5",
      ask: "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0zM9.4 9.3a2.7 2.7 0 1 1 3.9 2.4c-.8.4-1.3 1-1.3 1.9M12 17h.01",
    };
    const chip = (label, on, pick) => ({
      label: label,
      on: on,
      pick: pick,
      bg: on ? "var(--solid, var(--ink))" : "var(--card, #FFFFFF)",
      fg: on ? "var(--on-solid, #FFFFFF)" : INK,
      border: on ? "var(--solid, var(--ink))" : "var(--strong)",
    });
    const seg = (label, on, pick) => ({
      label: label,
      on: on,
      pick: pick,
      bg: on ? "var(--seg-on, var(--card, #FFFFFF))" : "transparent",
      weight: on ? 700 : 600,
      shadow: on ? "0 1px 3px rgba(43,31,82,0.18)" : "none",
    });
    const ruled = (list) => list.map((x, i) => Object.assign({}, x, { rule: i === 0 ? "transparent" : "var(--rule)" }));
    const fmt = (t) => {
      const p = String(t).split(":");
      const h = +p[0];
      const m = +p[1] || 0;
      return (h % 12 || 12) + ":" + (m < 10 ? "0" : "") + m + " " + (h >= 12 ? "PM" : "AM");
    };
    const mins = (t) => {
      const p = String(t).split(":");
      return +p[0] * 60 + (+p[1] || 0);
    };
    const person = (p) => Object.assign({}, p, { open: () => this.setState({ sheet: "contact", contactId: p.id }) });
    const toPeople = (extra) => Object.assign({ dept: null, office: null, org: null, center: null }, extra);

    const tabs = [
      ["home", "Home", I.home],
      ["people", "People", I.people],
      ["help", "Help", I.ask],
      ["map", "Map", I.map],
      ["more", "More", I.more],
    ].map((t) => {
      const on = s.tab === t[0] || (t[0] === "more" && s.tab === "planner");
      return { label: t[1], icon: t[2], current: on ? "page" : undefined, color: on ? "var(--nav-on, var(--accent))" : "var(--nav-sub, var(--sub))", weight: on ? 700 : 600, go: () => this.go(t[0]) };
    });

    // Directory
    const dq = s.dirQuery.trim().toLowerCase();
    const dirAll = this.people.filter((c) => (s.filter === "All" || (s.filter === "Faculty") === c.fac) && (!dq || c.hay.indexOf(dq) !== -1));
    const dirList = ruled(dirAll.slice(0, CAP).map(person));
    const dirCount =
      dirAll.length > CAP
        ? "Showing " + CAP + " of " + dirAll.length + ". Search to narrow it down."
        : dirAll.length + (dirAll.length === 1 ? " person" : " people");
    const curP = this.people[s.contactId] || null;
    const curFav = curP ? !!s.favs[curP.email] : false;
    const cur = curP ? Object.assign({}, curP, { fav: curFav, starFill: curFav ? "currentColor" : "none", favLabel: curFav ? "Saved" : "Save" }) : {};
    const contactRows = curP
      ? ruled([
          { label: "Department", value: curP.dept },
          { label: "Office", value: curP.office },
          { label: "Email", value: curP.email },
        ])
      : [];
    const favs = this.people.filter((c) => s.favs[c.email]).map(person);

    // Departments
    const dpq = s.deptQuery.trim().toLowerCase();
    const deptAll = this.depts.filter((d) => !dpq || d.hay.indexOf(dpq) !== -1);
    const depts = ruled(
      deptAll.slice(0, CAP).map((d) => ({ name: d.name, count: d.n + (d.n === 1 ? " person" : " people"), open: () => this.setState({ dept: d.name }) })),
    );
    const deptCount =
      deptAll.length > CAP
        ? "Showing " + CAP + " of " + deptAll.length + ". Search to narrow it down."
        : deptAll.length + (deptAll.length === 1 ? " department" : " departments");
    const deptPeople = [];
    if (s.dept) {
      const members = this.people.filter((c) => c.dept === s.dept).sort((x, y) => x.level - y.level || (x.name < y.name ? -1 : 1));
      [
        ["Leadership", (c) => c.level <= 8],
        ["Faculty", (c) => c.level > 8 && c.fac],
        ["Staff", (c) => c.level > 8 && !c.fac],
      ].forEach((g) => {
        members
          .filter(g[1])
          .forEach((c, i) => deptPeople.push(Object.assign(person(c), { showHead: i === 0, head: g[0], rule: i === 0 ? "transparent" : "var(--rule)" })));
      });
    }
    const dmeta = (s.dept && this.DM[s.dept]) || ["", ""];

    // Who to ask (offices)
    const hq = s.helpQuery.trim().toLowerCase();
    const helpAll = this.offices.filter((f) => !hq || f.hay.indexOf(hq) !== -1);
    const helpList = helpAll.map((f, i) => {
      const first = i === 0 || helpAll[i - 1].category !== f.category;
      return {
        title: f.goHereFor,
        sub: f.name,
        showHead: first,
        head: f.category,
        rule: first ? "transparent" : "var(--rule)",
        open: () => this.setState(f.id === "learning" ? { pv: "tutor", center: null } : { office: f.id }),
      };
    });
    const curOffice = this.offices.find((f) => f.id === s.office) || {};
    const officeRows = ruled(
      [
        ["Location", curOffice.location],
        ["Hours", curOffice.hours],
        ["Email", curOffice.email],
        ["Main line", curOffice.phone],
      ]
        .filter((r) => r[1])
        .map((r) => ({ label: r[0], value: r[1] })),
    );
    const officeDept = (curOffice.departments || [])[0];

    // Tutoring (learning centers)
    const tq = s.tutorQuery.trim().toLowerCase();
    const tutorAll = this.centers.filter((c) => !tq || c.hay.indexOf(tq) !== -1);
    const tutorList = tutorAll.map((c, i) => {
      const first = i === 0 || tutorAll[i - 1].cat !== c.cat;
      return {
        title: c.name,
        sub: c.building + (c.room ? " " + c.room : ""),
        showHead: first,
        head: c.cat,
        rule: first ? "transparent" : "var(--rule)",
        open: () => this.setState({ center: c.id }),
      };
    });
    const cc = this.centers.find((c) => c.id === s.center) || null;
    const curCenter = cc ? { category: cc.cat, name: cc.name, goHereFor: cc.subjects, note: cc.notes, website: cc.url, book: cc.book } : {};
    const centerRows = cc
      ? ruled(
          [
            ["Location", cc.building + (cc.room ? ", " + cc.room : "")],
            ["Hours", cc.hours + (cc.term ? " (" + cc.term + ")" : "")],
            ["How to get help", cc.how],
            ["Contact", cc.contact],
            ["Email", cc.email],
            ["Phone", cc.phone],
          ]
            .filter((r) => r[1])
            .map((r) => ({ label: r[0], value: r[1] })),
        )
      : [];

    // Student orgs
    const oq = s.orgQuery.trim().toLowerCase();
    const orgAll = this.orgs.filter((o) => (s.orgCat === "All" || o.cat === s.orgCat) && (!oq || o.hay.indexOf(oq) !== -1));
    const logo = (o, sz) =>
      o.li >= 0
        ? { lcls: "olg", lsz: 17 * sz + "px " + 16 * sz + "px", lpos: -(o.li % 17) * sz + "px " + -Math.floor(o.li / 17) * sz + "px", linit: "" }
        : {
            lcls: "onol",
            lsz: "auto",
            lpos: "0 0",
            linit: (o.short || o.name)
              .replace(/[^A-Za-z0-9]/g, "")
              .slice(0, 2)
              .toUpperCase(),
          };
    const orgs = ruled(orgAll.slice(0, CAP).map((o) => Object.assign(logo(o, 44), { name: o.name, cat: o.cat, open: () => this.setState({ org: o.i }) })));
    const orgCount =
      orgAll.length > CAP
        ? "Showing " + CAP + " of " + orgAll.length + ". Search to narrow it down."
        : orgAll.length + (orgAll.length === 1 ? " organization" : " organizations");
    const curOrg = s.org === null ? {} : Object.assign({}, this.orgs[s.org], logo(this.orgs[s.org], 72));

    // Classes
    const DAYS = [
      ["M", "Mon"],
      ["T", "Tue"],
      ["W", "Wed"],
      ["R", "Thu"],
      ["F", "Fri"],
    ];
    const subjName = (code) => {
      const m = this.subjects.find((x) => x[0] === code);
      return m ? m[1] : "Other subject";
    };
    const classes = ruled(
      s.classes
        .slice()
        .sort((x, y) => mins(x.start) - mins(y.start))
        .map((k) => {
          const code = k.subj + " " + k.num;
          const hc = this.centers.find((c) => c.codes.indexOf(k.subj) !== -1);
          const dayText = DAYS.filter((d) => k.days.indexOf(d[0]) !== -1)
            .map((d) => d[1])
            .join(", ");
          return Object.assign({}, k, {
            code: code,
            name: subjName(k.subj),
            time: fmt(k.start) + " – " + fmt(k.end),
            when: dayText + " · " + fmt(k.start) + " – " + fmt(k.end) + (k.loc ? " · " + k.loc : ""),
            hasHelp: !!hc,
            helpName: hc ? hc.name : "",
            openHelp: () => {
              if (hc) this.go("people", toPeople({ pv: "tutor", center: hc.id }));
            },
            removeLabel: "Remove " + code,
            remove: () => this.setState({ classes: s.classes.filter((x) => x.id !== k.id) }),
          });
        }),
    );
    const now = new Date();
    const nowMin = now.getHours() * 60 + now.getMinutes();
    const letters = ["", "M", "T", "W", "R", "F", ""];
    const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    let next = null;
    for (let d = 0; d < 7 && !next; d++) {
      const wd = (now.getDay() + d) % 7;
      const L = letters[wd];
      if (!L) continue;
      const todays = classes.filter((k) => k.days.indexOf(L) !== -1 && (d > 0 || mins(k.end) > nowMin));
      if (todays.length) {
        const k = todays[0];
        const live = d === 0 && mins(k.start) <= nowMin;
        next = {
          code: k.code,
          line: k.time + (k.loc ? " · " + k.loc : ""),
          label: live ? "Happening now" : "Up next · " + (d === 0 ? "Today" : d === 1 ? "Tomorrow" : dayNames[wd]),
        };
      }
    }
    const sq = s.cSubjQuery.trim().toLowerCase();
    const subjMatches =
      !s.cSubj && sq
        ? this.subjects
            .filter((x) => x[0].toLowerCase().indexOf(sq) === 0 || x[1].toLowerCase().indexOf(sq) !== -1)
            .slice(0, 6)
            .map((x) => ({ label: x[0] + " · " + x[1], pick: () => this.setState({ cSubj: x[0], cSubjQuery: x[0] + " · " + x[1], cErr: "" }) }))
        : [];
    const saveClass = () => {
      const typed = s.cSubjQuery.trim().toUpperCase();
      const subj = s.cSubj || (/^[A-Z]{2,5}$/.test(typed) ? typed : "");
      const num = s.cNum.trim();
      const days = DAYS.map((d) => d[0])
        .filter((k) => s.cDays[k])
        .join("");
      let err = "";
      if (!subj) err = "Pick a subject from the list, or type its code.";
      else if (!num) err = "Enter the course number.";
      else if (!days) err = "Choose at least one day.";
      else if (!s.cStart || !s.cEnd || mins(s.cEnd) <= mins(s.cStart)) err = "The end time has to be after the start time.";
      if (err) {
        this.setState({ cErr: err });
        return;
      }
      this.setState({
        classes: s.classes.concat([{ id: Date.now(), subj: subj, num: num, days: days, start: s.cStart, end: s.cEnd, loc: s.cLoc.trim() }]),
        sheet: null,
      });
    };

    // Tasks
    const tasks = ruled(s.tasks).map((t) =>
      Object.assign({}, t, {
        toggle: () => this.toggleTask(t.id),
        deco: t.done ? "line-through" : "none",
        op: t.done ? 0.55 : 1,
        boxBg: t.done ? "var(--accent-ink, var(--accent))" : "transparent",
        boxBorder: t.done ? "var(--accent-ink, var(--accent))" : "var(--check)",
        checkOp: t.done ? 1 : 0,
        checkLabel: (t.done ? "Mark not done: " : "Mark done: ") + t.type + ", " + t.course,
      }),
    );
    const dueSoon = tasks.filter((t) => !t.done).slice(0, 2);
    const courseOpts = [];
    classes.forEach((k) => {
      if (courseOpts.indexOf(k.code) === -1) courseOpts.push(k.code);
    });
    courseOpts.push("Other");
    const addCourse = courseOpts.indexOf(s.addCourse) !== -1 ? s.addCourse : courseOpts[0];

    // Search
    const tools = [
      {
        label: "Directory",
        sub: "Faculty and staff",
        icon: I.people,
        kw: "directory people contacts faculty staff professor",
        go: () => this.go("people", toPeople({ pv: "dir" })),
      },
      {
        label: "Get help",
        sub: "Find the right office",
        icon: I.help,
        kw: "who to ask help office problem",
        go: () => this.go("people", toPeople({ pv: "help" })),
      },
      {
        label: "Campus map",
        sub: "Buildings and floors",
        icon: I.map,
        kw: "map building library meem fisher union floor directions room",
        go: () => this.go("map"),
      },
      { label: "Common links", sub: "Canvas, Banweb, more", icon: I.link, kw: "links canvas banweb mymichigantech calendar", go: () => this.go("more") },
      {
        label: "Departments",
        sub: "People by department",
        icon: I.more,
        kw: "departments college office",
        go: () => this.go("people", toPeople({ pv: "depts" })),
      },
      {
        label: "Tutoring",
        sub: "Learning centers by subject",
        icon: I.help,
        kw: "tutor tutoring learning center coaching math physics writing",
        go: () => this.go("people", toPeople({ pv: "tutor" })),
      },
      {
        label: "Student orgs",
        sub: "Clubs and organizations",
        icon: I.flag,
        kw: "student organizations clubs greek sports",
        go: () => this.go("people", toPeople({ pv: "orgs" })),
      },
      {
        label: "Task planner",
        sub: "Assignments and exams",
        icon: I.planner,
        kw: "planner tasks homework assignment exam",
        go: () => this.go("planner", { planMode: "tasks" }),
      },
      {
        label: "My classes",
        sub: "Your class schedule",
        icon: I.clock,
        kw: "classes schedule class times",
        go: () => this.go("planner", { planMode: "times" }),
      },
      {
        label: "Emergency numbers",
        sub: "911 and campus lines",
        icon: I.phone,
        kw: "emergency 911 988 police safety counseling",
        go: () => this.setState({ sheet: "emergency" }),
      },
    ];
    const q = s.query.trim().toLowerCase();
    const peopleHits = q
      ? ruled(
          this.people
            .filter((c) => c.hay.indexOf(q) !== -1)
            .slice(0, 5)
            .map(person),
        )
      : [];
    const officeHits = q
      ? ruled(
          this.offices
            .filter((f) => f.hay.indexOf(q) !== -1)
            .slice(0, 4)
            .map((f) => ({ title: f.name, sub: f.goHereFor, open: () => this.go("people", toPeople({ pv: "help", office: f.id })) })),
        )
      : [];
    const orgHits = q
      ? ruled(
          this.orgs
            .filter((o) => o.hay.indexOf(q) !== -1)
            .slice(0, 4)
            .map((o) => ({ title: o.name, sub: o.cat, open: () => this.go("people", toPeople({ pv: "orgs", org: o.i })) })),
        )
      : [];
    const centerHits = q
      ? ruled(
          this.centers
            .filter((c) => c.hay.indexOf(q) !== -1)
            .slice(0, 4)
            .map((c) => ({
              title: c.name,
              sub: c.building + (c.room ? " " + c.room : ""),
              open: () => this.go("people", toPeople({ pv: "tutor", center: c.id })),
            })),
        )
      : [];
    const toolHits = q ? ruled(tools.filter((t) => (t.label + " " + t.kw).toLowerCase().indexOf(q) !== -1)) : [];
    const lingo = this.lingo;
    const lingoHits = q
      ? ruled(
          lingo
            .filter((l) => (l.term + " " + l.meaning).toLowerCase().indexOf(q) !== -1)
            .map((l) => Object.assign({}, l, { go: () => this.go("map", { building: l.b, floor: "1F", layer: "All" }) })),
        )
      : [];

    // Map
    const CAT = { Academic: "#1F4E79", Services: "#9C2F5B", Housing: "#8A5A00", Athletics: "#2E6B3F" };
    const blds = this.buildings;
    const buildings = blds.map((b) => {
      const on = s.building === b.id;
      const inLayer = s.layer === "All" || s.layer === b.layer;
      return Object.assign({}, b, {
        on: on,
        left: b.x - b.w / 2,
        top: b.y - b.h / 2,
        bg: CAT[b.layer],
        op: inLayer ? 1 : 0.25,
        shadow: on ? "0 0 0 3px #FFFFFF, 0 0 0 6px #111111" : "0 1px 2px rgba(0,0,0,0.3)",
        pick: () => this.setState({ building: b.id, floor: "1F" }),
      });
    });
    const curB = blds.find((b) => b.id === s.building) || {};
    const mapRef = (el) => {
      if (!el) return;
      const key = s.building || "home";
      if (el.getAttribute("data-k") === key) return;
      el.setAttribute("data-k", key);
      const cx = curB.x || 470;
      const cy = curB.y || 330;
      el.scrollLeft = Math.max(0, cx - el.clientWidth / 2);
      el.scrollTop = Math.max(0, cy - el.clientHeight / 2);
    };

    const numbers = this.numbers.map((n, i) =>
      Object.assign({}, n, {
        ask: () => this.setState({ confirm: i }),
        callLabel: "Call " + n.label,
        bg: n.primary ? "#B3261E" : "var(--card, #FFFFFF)",
        border: n.primary ? "#B3261E" : "#EBC4C0",
        fg: n.primary ? "#FFFFFF" : INK,
        btnBg: n.primary ? "#FFFFFF" : "#B3261E",
        btnFg: n.primary ? "#B3261E" : "#FFFFFF",
      }),
    );

    // Home widgets
    const WD = [
      ["next", "Next class", "Your upcoming class", true],
      ["cal", "This week", "A calendar of your classes", true],
      ["due", "Due soon", "Tasks from your planner", true],
      ["links", "Quick links", "Canvas, Banweb, and more", true],
      ["help", "Get help shortcuts", "Common needs, one tap away", false],
      ["saved", "Saved people", "Contacts you starred", true],
      ["org", "Student org of the day", "Discover a new organization", false],
      ["places", "People & places", "Shortcuts to the directory and map", false],
    ];
    const wOn = {};
    WD.forEach((w) => {
      wOn[w[0]] = w[0] in s.widgets ? !!s.widgets[w[0]] : w[3];
    });
    const widgetRows = ruled(
      WD.map((w) => ({
        label: w[1],
        sub: w[2],
        on: wOn[w[0]],
        swBg: wOn[w[0]] ? "var(--accent-ink, var(--accent))" : "var(--check)",
        swLeft: wOn[w[0]] ? 23 : 3,
        toggle: () => this.setState({ widgets: Object.assign({}, s.widgets, { [w[0]]: !wOn[w[0]] }) }),
      })),
    );
    const dow = now.getDay();
    const monday = new Date(now.getFullYear(), now.getMonth(), now.getDate() + (dow === 0 ? 1 : dow === 6 ? 2 : 1 - dow));
    const calSel = s.calDay === null ? (dow >= 1 && dow <= 5 ? dow - 1 : 0) : s.calDay;
    const calDays = DAYS.map((d, i) => {
      const date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
      const isToday = date.toDateString() === now.toDateString();
      const count = classes.filter((k) => k.days.indexOf(d[0]) !== -1).length;
      return Object.assign(
        chip(d[1], calSel === i, () => this.setState({ calDay: i })),
        {
          top: isToday ? "Today" : d[1],
          num: date.getDate(),
          dots: "•••••".slice(0, Math.min(count, 4)),
          aria: dayNames[i + 1] + ", " + count + (count === 1 ? " class" : " classes"),
        },
      );
    });
    const calList = classes.filter((k) => k.days.indexOf(DAYS[calSel][0]) !== -1);
    const helpChips = [
      ["Transcript", "registrar"],
      ["Parking", "parking"],
      ["Tutoring", "learning"],
      ["Financial aid", "finaid"],
      ["Counseling", "counseling"],
      ["IT help", "it"],
      ["Housing", "housing"],
    ].map((h) => ({ label: h[0], pick: () => this.go("people", toPeople(h[1] === "learning" ? { pv: "tutor" } : { pv: "help", office: h[1] })) }));
    const spot = this.orgs[Math.floor(now.getTime() / 86400000) % this.orgs.length];
    const orgSpot = Object.assign(logo(spot, 48), {
      name: spot.name,
      cat: spot.cat,
      desc: spot.desc.length > 150 ? spot.desc.slice(0, 150).replace(/\s+\S*$/, "") + "…" : spot.desc,
      open: () => this.go("people", toPeople({ pv: "orgs", org: spot.i })),
    });

    const sheet = s.sheet;
    const pv = s.pv;
    return {
      accent: accent,
      tabs: tabs,
      theme: s.theme,
      quickLinks: this.links,
      about: this.about,
      modeClass: s.dark && s.user ? "dark" : "",
      signedOut: !s.user,
      siEmail: s.siEmail,
      siErr: s.siErr,
      hasSiErr: !!s.siErr,
      onSiEmail: (e) => this.setState({ siEmail: e.target.value, siErr: "" }),
      onSiKey: (e) => {
        if (e.key === "Enter") this.signIn();
      },
      signIn: () => this.signIn(),
      signOut: () => this.signOut(),
      demoAccounts: this.schools.map((sc) => ({ label: "you@" + sc.domain, pick: () => this.signIn("you@" + sc.domain) })),
      account: { school: (this.schools.find((sc) => s.user && sc.id === s.user.school) || {}).name || "", email: s.user ? s.user.email : "" },
      dark: {
        on: s.dark,
        swBg: s.dark ? "var(--accent-ink, var(--accent))" : "var(--check)",
        swLeft: s.dark ? 23 : 3,
        toggle: () => this.setState({ dark: !s.dark }),
      },
      isHome: s.tab === "home",
      isPeople: s.tab === "people",
      isMap: s.tab === "map",
      isPlanner: s.tab === "planner",
      isMore: s.tab === "more",
      openEmergency: () => this.setState({ sheet: "emergency" }),
      openSearch: () => this.setState({ sheet: "search", query: "" }),
      openAdd: () => this.setState({ sheet: "add" }),
      closeSheet: () => this.setState({ sheet: null }),
      goTimes: () => this.go("planner", { planMode: "times" }),
      goPlanner: () => this.go("planner", { planMode: "tasks" }),
      hasNext: !!next,
      noNext: !next,
      next: next || {},
      nextEmptyTitle: s.classes.length ? "No classes coming up" : "Add your classes",
      nextEmptySub: s.classes.length ? "Nothing on your schedule this week." : "Build your schedule and your next class shows up here.",
      dueSoon: dueSoon,
      noDue: dueSoon.length === 0,
      favs: favs,
      hasFavs: wOn.saved && favs.length > 0,
      wNext: wOn.next,
      wCal: wOn.cal,
      wDue: wOn.due,
      wLinks: wOn.links,
      wHelp: wOn.help,
      wOrg: wOn.org,
      wPlaces: wOn.places,
      widgetRows: widgetRows,
      todayText: now.toLocaleDateString("en-US", { weekday: "long", month: "long", day: "numeric" }),
      calDays: calDays,
      calList: calList,
      hasCal: calList.length > 0,
      calEmpty: calList.length === 0,
      calEmptyText: s.classes.length ? "No classes on " + dayNames[calSel + 1] + "." : "Add your classes to fill in the week.",
      helpChips: helpChips,
      orgSpot: orgSpot,
      goOrgs: () => this.go("people", toPeople({ pv: "orgs" })),
      shortcuts: tools.slice(0, 4),
      peopleSegs: (s.tab === "help"
        ? [
            ["help", "Get help"],
            ["tutor", "Tutoring"],
          ]
        : [
            ["dir", "Directory"],
            ["depts", "Departments"],
            ["orgs", "Student orgs"],
          ]
      ).map((g) => seg(g[1], pv === g[0], () => this.go(s.tab, toPeople({ pv: g[0] })))),
      isPH: s.tab === "people" || s.tab === "help",
      isHelp: s.tab === "help",
      phTitle: s.tab === "help" ? "Help" : "People",
      planBack: () => this.go(s.prevTab || "home"),
      isDir: pv === "dir",
      dirQuery: s.dirQuery,
      onDirQuery: (e) => this.setState({ dirQuery: e.target.value }),
      filters: ["All", "Faculty", "Staff"].map((f) => chip(f, s.filter === f, () => this.setState({ filter: f }))),
      dirCount: dirCount,
      dirLoading: s.dirLoading,
      dirReady: !s.dirLoading && dirList.length > 0,
      dirEmpty: !s.dirLoading && dirList.length === 0,
      dirList: dirList,
      clearDir: () => this.setState({ dirQuery: "", filter: "All" }),
      isDeptList: pv === "depts" && !s.dept,
      isDeptPage: pv === "depts" && !!s.dept,
      deptQuery: s.deptQuery,
      onDeptQuery: (e) => this.setState({ deptQuery: e.target.value }),
      deptCount: deptCount,
      depts: depts,
      hasDepts: depts.length > 0,
      noDepts: depts.length === 0,
      deptPeople: deptPeople,
      curDept: s.dept || "",
      curDeptCat: dmeta[0],
      curDeptReports: dmeta[1],
      hasReports: !!dmeta[1],
      backDepts: () => this.setState({ dept: null }),
      isHelpList: pv === "help" && !s.office,
      isHelpPage: pv === "help" && !!s.office,
      helpQuery: s.helpQuery,
      onHelpQuery: (e) => this.setState({ helpQuery: e.target.value }),
      helpList: helpList,
      hasHelp: helpList.length > 0,
      noHelp: helpList.length === 0,
      curOffice: curOffice,
      officeRows: officeRows,
      hasOfficeNote: !!curOffice.note,
      hasOfficeSite: !!curOffice.website,
      hasOfficePeople: !!officeDept,
      officeToDept: () => this.go("people", toPeople({ pv: "depts", dept: officeDept })),
      backHelp: () => this.setState({ office: null }),
      isOrgList: pv === "orgs" && s.org === null,
      isOrgPage: pv === "orgs" && s.org !== null,
      orgQuery: s.orgQuery,
      onOrgQuery: (e) => this.setState({ orgQuery: e.target.value }),
      orgCats: ["All"].concat(this.orgCatNames).map((f) => chip(f, s.orgCat === f, () => this.setState({ orgCat: f }))),
      orgCount: orgCount,
      orgs: orgs,
      hasOrgs: orgs.length > 0,
      noOrgs: orgs.length === 0,
      curOrg: curOrg,
      orgRows: curOrg.email ? [{ label: "Email", value: curOrg.email, rule: "transparent" }] : [],
      hasOrgEmail: !!curOrg.email,
      hasOrgSite: !!curOrg.site,
      backOrgs: () => this.setState({ org: null }),
      isTutorList: pv === "tutor" && !s.center,
      isTutorPage: pv === "tutor" && !!s.center,
      tutorQuery: s.tutorQuery,
      onTutorQuery: (e) => this.setState({ tutorQuery: e.target.value }),
      tutorList: tutorList,
      hasTutor: tutorList.length > 0,
      noTutor: tutorList.length === 0,
      backTutor: () => this.setState({ center: null }),
      curCenter: curCenter,
      centerRows: centerRows,
      hasCenterNote: !!curCenter.note,
      hasCenterSite: !!curCenter.website,
      hasCenterBook: !!curCenter.book,
      hasCenterMap: !!(cc && cc.map),
      centerToMap: () => {
        if (cc) this.go("map", { building: cc.map, floor: "1F", layer: "All" });
      },
      centerHits: centerHits,
      hasCenterHits: centerHits.length > 0,
      layers: ["All", "Academic", "Services", "Housing", "Athletics"].map((f) =>
        Object.assign(
          chip(f, s.layer === f, () => this.setState({ layer: f })),
          { dot: CAT[f] || "#8C939B" },
        ),
      ),
      mapRef: mapRef,
      buildings: buildings,
      noBuilding: !s.building,
      hasBuilding: !!s.building,
      curB: curB,
      floor: s.floor,
      floors: ["1F", "2F", "3F"].map((f) => chip(f, s.floor === f, () => this.setState({ floor: f }))),
      planSegs: [
        seg("Tasks", s.planMode === "tasks", () => this.setState({ planMode: "tasks" })),
        seg("My classes", s.planMode === "times", () => this.setState({ planMode: "times" })),
      ],
      isTasks: s.planMode === "tasks",
      isTimes: s.planMode === "times",
      tasks: tasks,
      hasTasks: tasks.length > 0,
      noTasks: tasks.length === 0,
      classes: classes,
      hasClasses: classes.length > 0,
      noClasses: classes.length === 0,
      openClass: () => this.setState({ sheet: "class", cSubj: null, cSubjQuery: "", cNum: "", cDays: {}, cStart: "10:00", cEnd: "10:50", cLoc: "", cErr: "" }),
      cSubjQuery: s.cSubjQuery,
      onCSubj: (e) => this.setState({ cSubjQuery: e.target.value, cSubj: null }),
      subjMatches: subjMatches,
      hasSubjMatches: subjMatches.length > 0,
      cNum: s.cNum,
      onCNum: (e) => this.setState({ cNum: e.target.value }),
      dayBtns: DAYS.map((d) => chip(d[1], !!s.cDays[d[0]], () => this.setState({ cDays: Object.assign({}, s.cDays, { [d[0]]: !s.cDays[d[0]] }), cErr: "" }))),
      cStart: s.cStart,
      onCStart: (e) => this.setState({ cStart: e.target.value }),
      cEnd: s.cEnd,
      onCEnd: (e) => this.setState({ cEnd: e.target.value }),
      cLoc: s.cLoc,
      onCLoc: (e) => this.setState({ cLoc: e.target.value }),
      cErr: s.cErr,
      hasCErr: !!s.cErr,
      saveClass: saveClass,
      showToast: !!s.toast,
      toastText: s.toast ? s.toast.text : "",
      toastBottom: s.tab === "home" ? 172 : 96,
      undo: () => {
        if (s.toast) {
          this.toggleTask(s.toast.id);
        }
      },
      showSheet: !!sheet,
      showEmergency: sheet === "emergency",
      showContact: sheet === "contact",
      showAdd: sheet === "add",
      showSearch: sheet === "search",
      showClass: sheet === "class",
      numbers: numbers,
      showConfirm: s.confirm !== null,
      confirm: s.confirm !== null ? numbers[s.confirm] : {},
      cancelCall: () => this.setState({ confirm: null }),
      cur: cur,
      contactRows: contactRows,
      toggleFav: () => {
        if (curP) this.setState({ favs: Object.assign({}, s.favs, { [curP.email]: !s.favs[curP.email] }) });
      },
      contactToMap: () => this.go("map"),
      contactToDept: () => {
        if (curP) this.go("people", toPeople({ pv: "depts", dept: curP.dept }));
      },
      addTypes: ["Assignment", "Exam", "Project", "Reading", "Other"].map((f) => chip(f, s.addType === f, () => this.setState({ addType: f }))),
      addCourses: courseOpts.map((f) => chip(f, addCourse === f, () => this.setState({ addCourse: f }))),
      saveTask: () =>
        this.setState({ tasks: s.tasks.concat([{ id: Date.now(), type: s.addType, course: addCourse, due: "No date", done: false }]), sheet: null }),
      query: s.query,
      onQuery: (e) => this.setState({ query: e.target.value }),
      searchIdle: !q,
      suggestions: ["Transcript", "Parking", "Tutoring", "MUB"].map((f) => ({ label: f, pick: () => this.setState({ query: f }) })),
      lingoHits: lingoHits,
      hasLingoHits: lingoHits.length > 0,
      peopleHits: peopleHits,
      hasPeopleHits: peopleHits.length > 0,
      officeHits: officeHits,
      hasOfficeHits: officeHits.length > 0,
      orgHits: orgHits,
      hasOrgHits: orgHits.length > 0,
      toolHits: toolHits,
      hasToolHits: toolHits.length > 0,
      noHits:
        !!q &&
        peopleHits.length === 0 &&
        toolHits.length === 0 &&
        lingoHits.length === 0 &&
        officeHits.length === 0 &&
        orgHits.length === 0 &&
        centerHits.length === 0,
    };
  }
}
