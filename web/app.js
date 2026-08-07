"use strict";

/* ==========================================================================
   Habit Circle — web prototype logic.
   Mirrors HomeViewModel, DiscoverViewModel and HabitDetailViewModel so the
   prototype behaves like the SwiftUI app running in the simulator.
   ========================================================================== */

/* ---------- Design tokens (AppColors.swift / TaskCategory) ---------- */
const ACCENTS = {
  routine: { accent: "#FBC500", tint: "#FFF9E5", icon: "assets/circle-routine.png" },
  food:    { accent: "#0EB47F", tint: "#E7F7F2", icon: "assets/circle-eating.png" },
  fitness: { accent: "#F78FC6", tint: "#FEF4F9", icon: "assets/circle-fitness.png" },
  misc:    { accent: "#A378E0", tint: "#F5EEFF", icon: "assets/circle-misc.png" },
};
/* iPhone 17 logical screen size (Figma frame "all tasks": 402 x 874). */
const PHONE_W = 402;
const PHONE_H = 874;

const LIGHT_GRAY = "#EFF4F6";
const MEDIUM_GRAY = "#D1DBDE";
/// Figma tints the gloss on a completed pill to #FCD6EA against the #F78FC6 accent,
/// which is the accent lightened ~62% toward white. Derived so every category works.
const GLOSS_LIGHTEN = 0.62;

/* ---------- SF Symbols-inspired icon set ---------- */
const svg = (inner, vb = "0 0 24 24") =>
  `<svg class="ic" viewBox="${vb}" fill="currentColor" xmlns="http://www.w3.org/2000/svg">${inner}</svg>`;
const stroke = (d, w = 2) =>
  `<path d="${d}" fill="none" stroke="currentColor" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;

/// checkmark.seal.fill — 12-lobe scalloped badge.
function sealPath() {
  const lobes = 12;
  const cx = 12, cy = 12, outer = 11, inner = 9.3;
  let d = "";
  for (let i = 0; i < lobes; i++) {
    const a0 = (i / lobes) * Math.PI * 2 - Math.PI / 2;
    const a1 = ((i + 0.5) / lobes) * Math.PI * 2 - Math.PI / 2;
    const a2 = ((i + 1) / lobes) * Math.PI * 2 - Math.PI / 2;
    const p = (r, a) => `${(cx + r * Math.cos(a)).toFixed(2)} ${(cy + r * Math.sin(a)).toFixed(2)}`;
    if (i === 0) d += `M${p(inner, a0)}`;
    d += `Q${p(outer, a1)} ${p(inner, a2)}`;
  }
  return d + "Z";
}

const ICONS = {
  "house-fill": svg('<path d="M3.6 11.5 12 4.6l8.4 6.9V19.4a1.3 1.3 0 0 1-1.3 1.3h-4.4v-6a.9.9 0 0 0-.9-.9h-3.6a.9.9 0 0 0-.9.9v6H4.9a1.3 1.3 0 0 1-1.3-1.3z"/>'),
  person: svg('<path d="M12 12.6a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4.5 19.6c0-3.7 3.5-5.7 7.5-5.7s7.5 2 7.5 5.7v.4h-15z"/>'),
  // person.2.fill — larger figure in front (left), smaller one behind (right).
  person2: svg(
    '<circle cx="16.5" cy="8.3" r="2.9"/>' +
    '<path d="M16.5 12.4c3 0 5.4 1.6 5.4 3.6 0 .9-.6 1.4-1.7 1.4h-3.9c.1-.4.2-.9.2-1.4 0-1.4-.6-2.6-1.7-3.5.5-.1 1.1-.1 1.7-.1z"/>' +
    '<circle cx="9.2" cy="7.5" r="3.7"/>' +
    '<path d="M9.2 12.5c3.8 0 6.8 2 6.8 4.4 0 1.1-.8 1.8-2.1 1.8H4.5c-1.3 0-2.1-.7-2.1-1.8 0-2.4 3-4.4 6.8-4.4z"/>'
  ),
  "bubble-left": svg('<path d="M12 3.6C6.9 3.6 3 6.9 3 11c0 2.2 1.1 4.2 3 5.6-.1.9-.6 2.1-1.4 3-.3.4 0 .9.5.8 2-.4 3.4-1.1 4.2-1.7.9.2 1.8.3 2.7.3 5.1 0 9-3.3 9-7.4S17.1 3.6 12 3.6z" fill="none" stroke="currentColor" stroke-width="1.7"/>'),
  search: svg('<circle cx="10.5" cy="10.5" r="6.3" fill="none" stroke="currentColor" stroke-width="2.1"/>' + stroke("M15.3 15.3 20.5 20.5", 2.1)),
  // SF "camera" is an outline symbol, not a filled one.
  camera: svg(
    '<path d="M9.4 4.7h5.2l1.2 2.3h3.5A2.7 2.7 0 0 1 22 9.7v7.6a2.7 2.7 0 0 1-2.7 2.7H4.7A2.7 2.7 0 0 1 2 17.3V9.7A2.7 2.7 0 0 1 4.7 7h3.5z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>' +
    '<circle cx="12" cy="13.5" r="3.5" fill="none" stroke="currentColor" stroke-width="1.7"/>'
  ),
  "photo-stack": svg('<path d="M7 4h14a1.6 1.6 0 0 1 1.6 1.6v10A1.6 1.6 0 0 1 21 17.2H7A1.6 1.6 0 0 1 5.4 15.6V5.6A1.6 1.6 0 0 1 7 4z" fill="none" stroke="currentColor" stroke-width="1.7"/>' + stroke("M2.4 7.6v11A1.8 1.8 0 0 0 4.2 20.4h13.4", 1.7) + '<circle cx="10" cy="8.6" r="1.5"/><path d="M6.8 15.2 10.4 11.6l2.4 2.3 2.8-3 3.4 4.3z"/>'),
  heart: svg('<path d="M12 20.4 10.6 19C5.4 14.3 2.4 11.6 2.4 8.2 2.4 5.7 4.3 3.8 6.8 3.8c1.6 0 3 .7 3.9 1.9l1.3 1.6 1.3-1.6c.9-1.2 2.3-1.9 3.9-1.9 2.5 0 4.4 1.9 4.4 4.4 0 3.4-3 6.1-8.2 10.8z" fill="none" stroke="currentColor" stroke-width="1.8"/>'),
  "heart-fill": svg('<path d="M12 20.4 10.6 19C5.4 14.3 2.4 11.6 2.4 8.2 2.4 5.7 4.3 3.8 6.8 3.8c1.6 0 3 .7 3.9 1.9l1.3 1.6 1.3-1.6c.9-1.2 2.3-1.9 3.9-1.9 2.5 0 4.4 1.9 4.4 4.4 0 3.4-3 6.1-8.2 10.8z"/>'),
  "chevron-left": svg(stroke("M15 4.5 8 12l7 7.5", 2.2)),
  "chevron-right": svg(stroke("M9 4.5 16 12l-7 7.5", 2.2)),
  checkmark: svg(stroke("M5 12.5 9.5 17 19 6.5", 2.6)),
  "checkmark-seal": svg(`<path d="${sealPath()}"/>` + '<path d="M8.1 12.3 10.8 15 16 8.9" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'),
  /// arrow.uturn.backward — swipe-right undo affordance on completed rows.
  undo: svg(
    stroke("M9 14 4 9l5-5", 2.4) +
    '<path d="M4 9h9a5 5 0 0 1 0 10h-3" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>'
  ),
  plus: svg(stroke("M12 5v14M5 12h14", 2.2)),
  xmark: svg(stroke("M6 6l12 12M18 6 6 18", 2.6)),
  "arrow-up": svg(stroke("M12 19V5M5.5 11.5 12 5l6.5 6.5", 2.2)),
  "triangle-down": svg('<path d="M12 17.5 3.8 6.5h16.4z"/>'),
  /// arrowtriangle.down.fill — the "today" marker above the weekday strip. Drawn as a
  /// smaller triangle grown by a round-joined stroke, which gives Figma's soft corners
  /// while keeping the shape flush with the 13x12 box.
  "triangle-marker": svg(
    '<path d="M2.2 2.2 L10.8 2.2 L6.5 9.8 Z" stroke="currentColor" stroke-width="4.4" stroke-linejoin="round"/>',
    "0 0 13 12"
  ),
  // mic.fill
  mic: svg(
    '<rect x="8.7" y="2.4" width="6.6" height="12" rx="3.3"/>' +
    '<path d="M5.9 11.2v.5a6.1 6.1 0 0 0 12.2 0v-.5" fill="none" stroke="currentColor" stroke-width="2"/>' +
    '<path d="M12 17.9v3.5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>'
  ),
  // material-symbols:lock — filled body with a stroked shackle.
  lock: svg(
    '<path d="M7.4 10.6V7.9a4.6 4.6 0 0 1 9.2 0v2.7" fill="none" stroke="currentColor" stroke-width="2.1"/>' +
    '<rect x="4.3" y="10.2" width="15.4" height="11.4" rx="2.8"/>'
  ),
  globe: svg(
    '<circle cx="12" cy="12" r="9.1" fill="none" stroke="currentColor" stroke-width="1.9"/>' +
    stroke("M3.2 9.2h17.6M3.2 14.8h17.6", 1.9) +
    '<path d="M12 2.9c2.3 2.4 3.5 5.4 3.5 9.1s-1.2 6.7-3.5 9.1c-2.3-2.4-3.5-5.4-3.5-9.1S9.7 5.3 12 2.9z" fill="none" stroke="currentColor" stroke-width="1.9"/>'
  ),
  /// The 12.98x8 dropdown arrow, drawn small and grown by a round-joined stroke so the
  /// tips stay as soft as Figma's rounded polygon.
  "caret-down": svg(
    '<path d="M6.49 6.55 1.25 1.15h10.48z" stroke="currentColor" stroke-width="2.3" stroke-linejoin="round"/>',
    "0 0 13 8"
  ),
  alarm: svg('<circle cx="12" cy="13.2" r="7" fill="none" stroke="currentColor" stroke-width="1.8"/>' + stroke("M12 10.2v3.4l2.2 1.4", 1.8) + stroke("M4.6 6.2 7.2 3.8", 1.8) + stroke("M19.4 6.2 16.8 3.8", 1.8)),
  /// person.badge.plus — Discover "Join to view" gate.
  "person-badge-plus": svg(
    '<path d="M11 12.2a3.6 3.6 0 1 0 0-7.2 3.6 3.6 0 0 0 0 7.2z"/>' +
    '<path d="M4.2 19.2c0-3.2 3-5 6.8-5 1.1 0 2.1.1 3 .4"/>' +
    '<circle cx="17.6" cy="15.4" r="4.2" fill="none" stroke="currentColor" stroke-width="1.7"/>' +
    stroke("M17.6 13.4v4M15.6 15.4h4", 1.7)
  ),
};

function injectStaticIcons(root = document) {
  root.querySelectorAll("[data-icon]").forEach((n) => {
    const name = n.getAttribute("data-icon");
    if (ICONS[name]) n.innerHTML = ICONS[name];
  });
}

/* ---------- Helpers ---------- */
const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
const el = (tag, cls, html) => {
  const n = document.createElement(tag);
  if (cls) n.className = cls;
  if (html != null) n.innerHTML = html;
  return n;
};
const clamp = (v, lo, hi) => Math.min(Math.max(v, lo), hi);
const escapeHTML = (s) =>
  String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

function hexToRGB(hex) {
  const h = hex.replace("#", "");
  return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
}
/// Linear RGB interpolation — mirrors ProgressRing.blend(_:_:_:).
function blendHex(from, to, t) {
  const a = hexToRGB(from);
  const b = hexToRGB(to);
  const tt = clamp(t, 0, 1);
  const c = a.map((v, i) => Math.round(v + (b[i] - v) * tt));
  return `rgb(${c[0]}, ${c[1]}, ${c[2]})`;
}

/* ==========================================================================
   HOME MODEL — HomeViewModel.swift
   ========================================================================== */
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const DOW = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const BASE_DATE = new Date(2026, 1, 12); // Thu, Feb 12 2026 — offset 0 == "today"
const MIN_OFFSET = -60;
const MAX_OFFSET = 60;

let _taskSeq = 0;
function mkTask(title, reminder, members, cat, opts = {}) {
  return {
    id: "task-" + _taskSeq++,
    title,
    reminderText: "Reminder " + reminder,
    members,
    cat,
    photo: !!opts.photo,
    done: false,
    circleName: opts.circle || `${title} Circle`,
    durationText: opts.duration || "1 month",
    frequencyText: "1/day",
    dayNumber: opts.day || 9,
    friendsDone: opts.friendsDone,
  };
}

const TASKS_BY_OFFSET = {
  "-1": [
    mkTask("Morning Run", "6:30AM", 8, "fitness"),
    mkTask("Meal Prep Lunches", "5:00PM", 12, "food"),
    mkTask("Read 20 Pages", "9:00PM", 1, "routine"),
    mkTask("Call Mom", "7:00PM", 1, "misc"),
  ],
  "0": [
    mkTask("Morning Stretch", "9:00AM", 1, "fitness"),
    mkTask("45g Protein Goal", "1:00PM", 24, "food"),
    mkTask("30-min Cardio", "7:00AM", 10, "fitness", { photo: true, circle: "Stairmasterers💪", duration: "1 month", day: 9, friendsDone: 7 }),
    mkTask("Write My Journal", "10:00AM", 1, "misc"),
    mkTask("Push-up Set", "6:00PM", 5, "fitness"),
    mkTask("Evening Skincare", "8:30PM", 1, "routine"),
    mkTask("Hydration Check-in", "3:00PM", 6, "food"),
    mkTask("Meditation Timer", "9:30PM", 3, "misc"),
  ],
  "1": [
    mkTask("Sunrise Yoga Flow", "8:00AM", 15, "fitness"),
    mkTask("No Sugar Day", "12:00PM", 30, "food"),
    mkTask("Plan The Weekend", "6:00PM", 1, "routine"),
    mkTask("Gratitude Journal", "10:00PM", 1, "misc", { photo: true }),
  ],
};

function dateForOffset(o) {
  const d = new Date(BASE_DATE);
  d.setDate(d.getDate() + o);
  return d;
}
function headerTitleFor(o) {
  const d = dateForOffset(o);
  return `${MONTHS[d.getMonth()]} ${d.getDate()}`;
}
function tasksFor(o) {
  return TASKS_BY_OFFSET[String(o)] || [];
}
// Completed tasks sink to the bottom; stable within each group (sortOrder).
function sortedTasks(o) {
  return tasksFor(o)
    .map((t, i) => [t, i])
    .sort((a, b) => Number(a[0].done) - Number(b[0].done) || a[1] - b[1])
    .map((pair) => pair[0]);
}

/* ---------- Discover model — DiscoverCircle.swift ---------- */
const CIRCLES = [
  { title: "Weight Training for Beginners", duration: "3 months", members: 10, category: "physical",
    icon: "assets/circle-fitness.png",
    desc: "Overcoming the fear of weights and empowered to get stronger in the gym!", liked: false },
  { title: "Healthy Vegans", duration: "2 weeks", members: 26, category: "eating",
    icon: "assets/circle-eating.png",
    desc: "Trying to find healthy, vegan meals that are tasty, inexpensive, and quick.", liked: false },
  { title: "Screen Time Under 4 Hours", duration: "6 months", members: 82, category: "routine",
    icon: "assets/circle-routine.png",
    desc: "Too much doom scrolling. Let's keep each other accountable with no phone time.", liked: false },
  { title: "Daily Gratitude Journal", duration: "1 month", members: 18, category: "misc",
    icon: "assets/circle-misc.png",
    desc: "Write three things you're grateful for each night. Small notes, big mindset shift.", liked: false },
  { title: "5-Minute Meditation", duration: "8 weeks", members: 34, category: "misc",
    icon: "assets/circle-misc.png",
    desc: "A short daily reset before the chaos starts. Breathe together, stay consistent.", liked: false },
];
const CATEGORIES = [
  { id: "physical", title: "Physical Health" },
  { id: "eating", title: "Healthy Eating" },
  { id: "routine", title: "Routine Building" },
  { id: "misc", title: "Miscellaneous" },
];
let selectedCategoryID = null;
let discoverSearch = "";

/* ==========================================================================
   NAVIGATION
   ========================================================================== */
function showScreen(name) {
  $$(".screen").forEach((s) => s.classList.toggle("active", s.dataset.screen === name));
  const isMain = name === "home" || name === "discover";
  $("#tabbar").classList.toggle("hidden", !isMain);
  $$(".tab").forEach((t) => t.classList.toggle("active", t.dataset.tab === name));
  const pill = $("#tabPill");
  if (pill) pill.dataset.active = name === "discover" ? "discover" : "home";

  if (name === "chat") {
    // The list only has a measurable height once the screen is displayed.
    requestAnimationFrame(() => scrollChatToEnd());
  }

  if (name === "detail") {
    $(".detail-scroll").scrollTop = 0;
  } else if (name === "discover") {
    const sc = $("#discoverScroll");
    if (sc) sc.scrollTop = 0;
  }
}

/* ==========================================================================
   HOME — rolling header, centered strip, day paging, swipe-to-complete
   ========================================================================== */
let selectedOffset = 0;
let lastSwipeTs = 0;

/* Rolling date header — .contentTransition(.numericText()) */
function renderHeader(text, dir) {
  const host = $("#homeTitle");
  const prev = host.__chars || [];
  const chars = text.split("");
  host.setAttribute("aria-label", text);
  host.innerHTML = "";

  chars.forEach((ch, i) => {
    const cell = el("span", "rc");
    const glyph = ch === " " ? "\u00A0" : ch;
    const inner = el("span", "rc-in", glyph);
    cell.appendChild(inner);
    host.appendChild(cell);

    if (dir !== 0 && prev[i] !== ch) {
      inner.style.transform = `translateY(${dir > 0 ? 110 : -110}%)`;
      inner.style.opacity = "0";
      requestAnimationFrame(() =>
        requestAnimationFrame(() => {
          inner.style.transform = "translateY(0)";
          inner.style.opacity = "1";
        })
      );
      if (prev[i]) {
        const ghost = el("span", "rc-in ghost", prev[i] === " " ? "\u00A0" : prev[i]);
        cell.appendChild(ghost);
        requestAnimationFrame(() =>
          requestAnimationFrame(() => {
            ghost.style.transform = `translateY(${dir > 0 ? -110 : 110}%)`;
            ghost.style.opacity = "0";
          })
        );
        setTimeout(() => ghost.remove(), 420);
      }
    }
  });
  host.__chars = chars;
}

/* Centered week strip — CenteredDateStrip */
function buildWeekStrip() {
  const track = $("#weekStripTrack");
  track.innerHTML = "";
  for (let o = MIN_OFFSET; o <= MAX_OFFSET; o++) {
    const d = dateForOffset(o);
    const cell = el("div", "day-cell");
    cell.dataset.offset = String(o);
    cell.innerHTML =
      `<div class="dow">${DOW[d.getDay()]}</div>` +
      `<div class="dom-wrap"><span class="dom">${d.getDate()}</span></div>`;
    cell.addEventListener("click", () => selectDay(o));
    track.appendChild(cell);
  }
}

function layoutWeekStrip(animate) {
  const strip = $("#weekStrip");
  const track = $("#weekStripTrack");
  // .weekstrip carries 16px horizontal padding, matching AppLayout.horizontalPadding.
  const w = strip.clientWidth - 32;
  if (w <= 0) return;
  if (!animate) strip.classList.add("no-anim");
  const slot = w / 7;
  $$(".day-cell", track).forEach((c) => {
    c.style.width = slot + "px";
    const off = Number(c.dataset.offset);
    const selected = off === selectedOffset;
    c.classList.toggle("selected", selected);
    const dow = $(".dow", c).textContent;
    c.classList.toggle("weekend", !selected && (dow === "Fri" || dow === "Sat" || dow === "Sun"));
  });
  const idx = selectedOffset - MIN_OFFSET;
  const tx = w / 2 - (idx + 0.5) * slot;
  track.style.transition = animate ? "transform .42s cubic-bezier(.2,.75,.2,1)" : "none";
  track.style.transform = `translateX(${tx}px)`;
  if (!animate) {
    void strip.offsetHeight; // flush the un-animated layout before re-enabling
    strip.classList.remove("no-anim");
  }
}

/* EmptyTasksView */
function emptyStateEl() {
  const wrap = el("div", "empty-state");
  wrap.innerHTML =
    `<div class="empty-badge">${ICONS["checkmark-seal"]}</div>` +
    `<div><div class="empty-title">All clear</div>` +
    `<p class="empty-sub">No tasks scheduled for this day.<br/>Enjoy the breather or add a new habit.</p></div>`;
  return wrap;
}

/* TaskCardView + SwipeToCompleteRow / swipe-right undo */
function buildSwipeRow(task) {
  const a = ACCENTS[task.cat];
  const row = el("div", "swipe-row" + (task.done ? " done" : "") + (task.photo ? " photo" : ""));
  row.dataset.id = task.id;
  row.style.setProperty("--tint", a.tint);
  row.style.setProperty("--accent", a.accent);
  const peopleIcon = task.members > 1 ? ICONS.person2 : ICONS.person;
  // Pending rows reveal a tinted checkmark from the trailing edge; done rows
  // reveal a grey undo arrow from the leading edge (SwipeActionBackground).
  const actionIcon = task.done ? ICONS.undo : ICONS.checkmark;
  row.innerHTML =
    `<div class="complete-action${task.done ? " undo" : ""}"><div class="ca-pill"><span class="ca-check">${actionIcon}</span></div></div>` +
    `<div class="task-card"${task.done ? "" : ` style="background:${a.tint}"`}>` +
      `<div class="t-row">` +
        `<img class="t-icon" src="${a.icon}" alt="" />` +
        `<div class="t-body">` +
          `<div class="t-title">${escapeHTML(task.title)}</div>` +
          `<div class="t-sub">` +
            `<span class="t-alarm">${ICONS.alarm}</span>` +
            `<span>${escapeHTML(task.reminderText)}</span>` +
            `<span>•</span>` +
            `<span class="t-people">${peopleIcon}</span>` +
            `<span>${task.members}</span>` +
          `</div>` +
        `</div>` +
      `</div>` +
      (task.photo
        ? `<button class="photo-verify-btn">${ICONS.camera}<span>Photo Verification</span></button>`
        : "") +
    `</div>`;
  return row;
}

function renderTaskList(listEl, offset) {
  listEl.innerHTML = "";
  sortedTasks(offset).forEach((task) => listEl.appendChild(buildSwipeRow(task)));
}

function buildDaySlot(offset) {
  const slot = el("div", "day-slot");
  slot.dataset.offset = String(offset);
  if (tasksFor(offset).length === 0) {
    slot.appendChild(emptyStateEl());
  } else {
    const scroll = el("div", "day-scroll");
    scroll.appendChild(el("p", "section-label", "My Tasks"));
    const listEl = el("div", "task-list");
    renderTaskList(listEl, offset);
    scroll.appendChild(listEl);
    slot.appendChild(scroll);
  }
  return slot;
}

// Rebuilds the 3-slot window (prev / current / next) centered on selectedOffset.
function renderDayTrack() {
  const track = $("#dayTrack");
  track.innerHTML = "";
  track.appendChild(buildDaySlot(selectedOffset - 1));
  track.appendChild(buildDaySlot(selectedOffset));
  track.appendChild(buildDaySlot(selectedOffset + 1));
  track.style.transition = "none";
  track.style.transform = "translateX(-33.3333%)";
}

function currentSlotEl() {
  return $("#dayTrack").children[1];
}

function selectDay(offset, dir) {
  offset = clamp(offset, MIN_OFFSET, MAX_OFFSET);
  const direction = dir !== undefined ? dir : offset > selectedOffset ? 1 : offset < selectedOffset ? -1 : 0;
  const changed = offset !== selectedOffset;
  selectedOffset = offset;
  renderDayTrack();
  layoutWeekStrip(true);
  renderHeader(headerTitleFor(offset), changed ? direction : 0);
}

/* ---------- Swipe-to-complete / swipe-right undo ---------- */
const SWIPE_GAP = 10; // SwipeActionLayout.actionGap

function updatePill(row, off, animate) {
  const card = $(".task-card", row);
  card.style.transition = animate ? "transform .34s cubic-bezier(.2,.8,.2,1)" : "none";
  card.style.transform = `translateX(${off}px)`;

  const rowW = row.clientWidth;
  const rowH = row.clientHeight;
  const undo = off > 0; // leading-edge reveal
  const pill = Math.max(0, Math.abs(off) - SWIPE_GAP);
  const minD = Math.min(68, rowH - 20);
  const vw = pill <= 4 ? 0 : Math.max(pill, minD);

  const expandEnd = rowH * 0.72;
  const prog = clamp((vw - minD) / (expandEnd - minD), 0, 1);
  const ph = minD + (rowH - minD) * prog;

  const action = $(".complete-action", row);
  const pillEl = $(".ca-pill", row);
  const check = $(".ca-check", row);
  action.classList.toggle("undo", undo || row.classList.contains("done"));
  pillEl.style.transition = animate
    ? "width .34s cubic-bezier(.2,.8,.2,1), height .34s cubic-bezier(.2,.8,.2,1)"
    : "none";
  pillEl.style.width = vw + "px";
  pillEl.style.height = (vw > 0 ? ph : minD) + "px";
  check.style.opacity = vw > 10 ? "1" : "0";
  // Past 80% the icon parks on the open edge (leading for complete, trailing for undo).
  pillEl.classList.toggle("lead", !undo && pill >= rowW * 0.8);
  pillEl.classList.toggle("trail", undo && pill >= rowW * 0.8);
  row.dataset.off = String(off);
}

function currentCardOffset(row) {
  return parseFloat(row.dataset.off || "0");
}
function springCardBack(row) {
  updatePill(row, 0, true);
}

function finishCardSwipe(row, isUndo) {
  const maxReveal = row.clientWidth * 0.92;
  const limit = maxReveal + SWIPE_GAP;
  updatePill(row, isUndo ? limit : -limit, true);
  setTimeout(() => {
    updatePill(row, 0, true);
    setTimeout(() => {
      const offset = Number(row.closest(".day-slot").dataset.offset);
      setTaskCompletedAndReflow(offset, row.dataset.id, !isUndo);
    }, 300);
  }, 170);
}

/// HomeViewModel.setCompleted — flips done and FLIP-animates the reorder.
function setTaskCompletedAndReflow(offset, id, isCompleted) {
  const task = tasksFor(offset).find((t) => t.id === id);
  if (!task || task.done === isCompleted) return;

  const slot = currentSlotEl();
  if (!slot || Number(slot.dataset.offset) !== offset) {
    task.done = isCompleted;
    return;
  }
  const listEl = $(".task-list", slot);
  const first = new Map();
  $$(".swipe-row", listEl).forEach((r) => first.set(r.dataset.id, r.getBoundingClientRect()));

  task.done = isCompleted;
  renderTaskList(listEl, offset);

  $$(".swipe-row", listEl).forEach((r) => {
    const f = first.get(r.dataset.id);
    if (!f) return;
    const l = r.getBoundingClientRect();
    const dx = f.left - l.left;
    const dy = f.top - l.top;
    if (!dx && !dy) return;
    r.style.transition = "none";
    r.style.transform = `translate(${dx}px, ${dy}px)`;
    requestAnimationFrame(() =>
      requestAnimationFrame(() => {
        r.style.transition = "transform .45s cubic-bezier(.2,.8,.2,1)";
        r.style.transform = "";
      })
    );
  });
}

function completeTaskAndReflow(offset, id) {
  setTaskCompletedAndReflow(offset, id, true);
}

/* ---------- Day paging ---------- */
function pageTo(dir) {
  const track = $("#dayTrack");
  track.style.transition = "transform .4s cubic-bezier(.2,.8,.2,1)";
  track.style.transform = `translateX(${dir > 0 ? -66.6666 : 0}%)`;
  const onEnd = (e) => {
    if (e.target !== track) return;
    track.removeEventListener("transitionend", onEnd);
    selectDay(selectedOffset + dir, dir);
  };
  track.addEventListener("transitionend", onEnd);
}
function settlePage() {
  const track = $("#dayTrack");
  track.style.transition = "transform .35s cubic-bezier(.2,.8,.2,1)";
  track.style.transform = "translateX(-33.3333%)";
}

/* ---------- Unified pointer gestures ---------- */
let drag = null;

function onPagerPointerDown(e) {
  if (e.pointerType === "mouse" && e.button !== 0) return;
  const cur = $("#dayTrack").children[1];
  const row = e.target.closest(".swipe-row");
  const onRow = row && cur.contains(row) ? row : null;
  drag = {
    startX: e.clientX, startY: e.clientY, x: e.clientX,
    t: performance.now(), vx: 0, axis: null, mode: null,
    // Done rows swipe right to undo; pending rows swipe left to complete.
    row: onRow,
    undo: !!(onRow && onRow.classList.contains("done")),
    pagerW: $("#dayPager").clientWidth,
  };
}

function onPagerPointerMove(e) {
  if (!drag) return;
  const dx = e.clientX - drag.startX;
  const dy = e.clientY - drag.startY;
  const now = performance.now();
  if (now !== drag.t) drag.vx = (e.clientX - drag.x) / (now - drag.t);
  drag.x = e.clientX;
  drag.t = now;

  if (drag.axis === null) {
    if (Math.abs(dx) < 8 && Math.abs(dy) < 8) return;
    drag.axis = Math.abs(dx) > Math.abs(dy) ? "h" : "v";
    if (drag.axis === "v") return; // let the day scroll vertically
    // Card swipe only in the action direction for that row; otherwise page days.
    const cardDir =
      drag.row && ((drag.undo && dx > 0) || (!drag.undo && dx < 0));
    drag.mode = cardDir ? "card" : "page";
  }
  if (drag.axis !== "h") return;
  e.preventDefault();

  if (drag.mode === "card") {
    const rowW = drag.row.clientWidth;
    const limit = rowW * 0.92 + SWIPE_GAP;
    const off = drag.undo
      ? Math.min(Math.max(0, dx), limit)
      : Math.max(Math.min(0, dx), -limit);
    updatePill(drag.row, off, false);
  } else {
    let d = dx;
    if ((selectedOffset <= MIN_OFFSET && d > 0) || (selectedOffset >= MAX_OFFSET && d < 0)) d *= 0.3;
    const track = $("#dayTrack");
    track.style.transition = "none";
    track.style.transform = `translateX(calc(-33.3333% + ${d}px))`;
  }
}

function onPagerPointerUp(e) {
  if (!drag) return;
  const d = drag;
  drag = null;
  if (d.axis !== "h" || !d.mode) return;
  lastSwipeTs = performance.now();

  if (d.mode === "card") {
    const rowW = d.row.clientWidth;
    const off = currentCardOffset(d.row);
    const pill = Math.max(0, Math.abs(off) - SWIPE_GAP);
    const flicked = d.undo ? d.vx > 0.9 : d.vx < -0.9;
    if (pill >= rowW * 0.52 || flicked) finishCardSwipe(d.row, d.undo);
    else springCardBack(d.row);
  } else {
    const dx = e.clientX - d.startX;
    const threshold = Math.min(90, d.pagerW * 0.25);
    const fast = Math.abs(d.vx) > 0.5;
    if ((dx < -threshold || (fast && d.vx < 0)) && selectedOffset < MAX_OFFSET) pageTo(1);
    else if ((dx > threshold || (fast && d.vx > 0)) && selectedOffset > MIN_OFFSET) pageTo(-1);
    else settlePage();
  }
}

function onPagerClick(e) {
  if (performance.now() - lastSwipeTs < 350) return;
  const card = e.target.closest(".task-card");
  if (!card) return;
  const row = card.closest(".swipe-row");
  if (currentCardOffset(row) !== 0) {
    springCardBack(row);
    return;
  }
  const offset = Number(row.closest(".day-slot").dataset.offset);
  const task = tasksFor(offset).find((t) => t.id === row.dataset.id);
  if (task) openDetail(task, offset);
}

function initHome() {
  buildWeekStrip();
  renderDayTrack();
  renderHeader(headerTitleFor(selectedOffset), 0);
  requestAnimationFrame(() => layoutWeekStrip(false));

  const pager = $("#dayPager");
  pager.addEventListener("pointerdown", onPagerPointerDown);
  window.addEventListener("pointermove", onPagerPointerMove, { passive: false });
  window.addEventListener("pointerup", onPagerPointerUp);
  window.addEventListener("pointercancel", onPagerPointerUp);
  pager.addEventListener("click", onPagerClick);
  window.addEventListener("resize", () => layoutWeekStrip(false));
}

/* ==========================================================================
   DISCOVER — DiscoverView / DiscoverCircleCard / CategoryChipRow
   ========================================================================== */
function filteredCircles() {
  const q = discoverSearch.trim().toLowerCase();
  return CIRCLES.filter((c) => {
    if (selectedCategoryID && c.category !== selectedCategoryID) return false;
    if (!q) return true;
    return c.title.toLowerCase().includes(q) || c.desc.toLowerCase().includes(q);
  });
}

function renderChips() {
  const chips = $("#chipRow");
  chips.innerHTML = "";
  CATEGORIES.forEach((cat) => {
    const chip = el("button", "chip" + (selectedCategoryID === cat.id ? " active" : ""), escapeHTML(cat.title));
    chip.addEventListener("click", () => {
      // Tapping the selected chip clears the selection (DiscoverViewModel.selectCategory).
      selectedCategoryID = selectedCategoryID === cat.id ? null : cat.id;
      renderChips();
      renderCircleList();
    });
    chips.appendChild(chip);
  });
}

/// DiscoverCircle.category / icon asset → TaskCategory for detail accents.
function circleCategory(c) {
  if (c.category === "physical" || c.icon.includes("fitness")) return "fitness";
  if (c.category === "eating" || c.icon.includes("eating")) return "food";
  if (c.category === "routine" || c.icon.includes("routine")) return "routine";
  return "misc";
}

/// DiscoverCircle.previewTask — locked habit opened from Join.
function previewTaskFromCircle(c) {
  return mkTask(c.title, "7:00AM", c.members, circleCategory(c), {
    photo: true,
    circle: c.title,
    duration: c.duration,
  });
}

function renderCircleList() {
  const list = $("#circleList");
  list.innerHTML = "";
  filteredCircles().forEach((c) => {
    const card = el("div", "circle-card");
    card.innerHTML =
      `<div class="cc-top">` +
        `<img src="${c.icon}" alt="" />` +
        `<div class="cc-text">` +
          `<div class="c-title">${escapeHTML(c.title)}</div>` +
          `<div class="c-meta">` +
            `<span class="c-duration">${escapeHTML(c.duration)}</span>` +
            `<span class="c-dot">•</span>` +
            `<span class="c-people">${ICONS.person2}</span>` +
            `<span class="c-count">${c.members}</span>` +
          `</div>` +
        `</div>` +
      `</div>` +
      `<div class="c-desc">${escapeHTML(c.desc)}</div>` +
      `<div class="cc-footer">` +
        `<button class="c-like ${c.liked ? "liked" : ""}" aria-label="Like">${c.liked ? ICONS["heart-fill"] : ICONS.heart}</button>` +
        `<button class="c-join">Join</button>` +
      `</div>`;
    const like = $(".c-like", card);
    like.addEventListener("click", (e) => {
      e.stopPropagation();
      c.liked = !c.liked;
      like.classList.toggle("liked", c.liked);
      like.innerHTML = c.liked ? ICONS["heart-fill"] : ICONS.heart;
    });
    // DiscoverView.onJoin → fullScreenCover HabitDetailView(isJoinLocked: true)
    $(".c-join", card).addEventListener("click", (e) => {
      e.stopPropagation();
      openDetail(previewTaskFromCircle(c), 0, { from: "discover", joinLocked: true });
    });
    list.appendChild(card);
  });
}

function renderDiscover() {
  renderChips();
  renderCircleList();
  $("#discoverSearch").addEventListener("input", (e) => {
    discoverSearch = e.target.value;
    renderCircleList();
  });
}

/* ==========================================================================
   HABIT DETAIL + CHAT — HabitDetailViewModel.swift
   ========================================================================== */
const RING_R = 126.957;  // Figma: 280/2 - 26.087/2
/// One live view model, recreated each time a habit is opened.
let vm = null;

/// Friends who already checked in today, never counting the user. A solo habit has
/// none, so its ring reads 0/1 (plain grey) until the user completes it and 1/1
/// (fully coloured) after — the two extremes of the ring.
function friendsCompletedToday(task, memberCount) {
  if (memberCount <= 1) return 0;
  const others = memberCount - 1;
  if (task.friendsDone != null) return clamp(task.friendsDone, 0, others);
  return clamp(Math.round(others * 0.75), 1, others);
}

function makeViewModel(task, offset, opts = {}) {
  const a = ACCENTS[task.cat];
  const memberCount = Math.max(task.members, 1);
  const completedCount = friendsCompletedToday(task, memberCount) + (task.done ? 1 : 0);
  const todayFraction = completedCount / memberCount;
  const isJoinLocked = !!opts.joinLocked;

  return {
    offset,
    taskID: task.id,
    title: task.title,
    circleName: task.circleName || `${task.title} Circle`,
    durationText: task.durationText,
    frequencyText: task.frequencyText,
    dayNumber: task.dayNumber,
    memberCount,
    completedCount,
    requiresPhoto: task.photo,
    accent: a.accent,
    tint: a.tint,
    icon: a.icon,
    isCompleted: task.done,
    /// Discover preview — content stays behind "Join to view" until join().
    isJoinLocked,
    /// Where Back should land (Discover fullScreenCover vs Home task tap).
    openedFrom: opts.from || "home",
    /// The circle chat is where members post their proof, so a habit that doesn't ask for
    /// a photo has no thread to open at all. A locked Discover preview has no chat either.
    hasChat: task.photo && !isJoinLocked,
    chatUnlocked: task.photo ? task.done : true,
    photoHistory: task.photo
      ? ["assets/gym-treadmill.png", "assets/gym-stairmaster.png", "assets/gym-console.png", "assets/gym-treadmill.png"]
      : [],
    draft: "",
    showAttachmentMenu: false,
    /// Set when the user taps "Verify with Photo": the habit completes once they pick
    /// a source, not on arrival.
    awaitingVerification: false,
    weekdays: [
      { label: "Sat", state: "completed", fraction: 1 },
      { label: "Sun", state: "partial", fraction: 0.575 },
      { label: "Mon", state: "completed", fraction: 1 },
      { label: "Tue", state: "today", fraction: todayFraction },
      { label: "Wed", state: "upcoming", fraction: 0 },
      { label: "Thu", state: "upcoming", fraction: 0 },
      { label: "Fri", state: "upcoming", fraction: 0 },
    ],
    /// Figma 1349:5338 — the thread is long enough to run up behind the blurred
    /// header, and ends on "u can do this guys!" so a verification photo posts last.
    messages: [
      { mine: false, type: "text", text: "who's on the treadmill today?", avatar: "Harry" },
      { mine: false, type: "text", text: "heading in right after work", avatar: "Harry" },
      { mine: false, type: "image", src: "assets/gym-treadmill.png", avatar: "Zoe" },
      { mine: false, type: "text", text: "any song recs for the cardio session?", avatar: "Zoe" },
      { mine: false, type: "image", src: "assets/gym-console.png", avatar: "Bob" },
      { mine: false, type: "text", text: "u can do this guys!", avatar: "Harry" },
    ],
    get progressFraction() {
      return this.memberCount > 0 ? Math.min(1, this.completedCount / this.memberCount) : 0;
    },
    get needsPhotoToUnlock() {
      return this.requiresPhoto && !this.chatUnlocked;
    },
    get canSend() {
      return this.draft.trim().length > 0;
    },
    get ctaTitle() {
      if (this.isCompleted) return "Completed";
      return this.requiresPhoto ? "Verify with Photo" : "Complete Habit";
    },
    get ctaIcon() {
      if (this.isCompleted) return "checkmark";
      return this.requiresPhoto ? "camera" : "checkmark";
    },
  };
}

/* ---------- Progress ring ----------
   Figma "habut circle complete": a 280x280.87 ring, centreline radius 126.957,
   stroke 26.087. The arc runs clockwise from 12 o'clock. Its radial gradient is
   centred on the start point, so the tail dissolves into the track while the
   head reaches full colour — the "solid at the end, fading tail" look.

   Closing out mirrors HabitDetailView.RingArcLayers: as the sweep nears 1 the
   fade shortens (closeProgress) so the ring seals itself instead of snapping. */
const RING_CIRC = 2 * Math.PI * RING_R;
const RING_HI_LAG = 2;      // degrees behind the arc's leading tip
/// The tail dissolves over this share of the arc travelled — measured off Figma, where
/// 8/10 reaches full colour around 160 of its 288 degrees. Expressing it as a share of
/// the sweep rather than a fixed angle keeps the fade clear of the tip at every size.
const RING_FADE_SHARE = 0.55;
const RING_FADE_MAX = 170;
const RING_CLOSE_START = 0.88; // fade begins closing up here (Swift closeFadeStart)
const RING_MS = 900;
/// Extra time when sealing all the way shut — gives the closeProgress fade room to breathe.
const RING_CLOSE_MS = 1200;

/* Fixed grey palette used until the user has completed the habit. */
const RING_GREY = { track: LIGHT_GRAY, head: "#898989", hi: LIGHT_GRAY };

function ringPalette() {
  if (!vm.isCompleted) return RING_GREY;
  return { track: vm.tint, head: vm.accent, hi: vm.tint };
}

/// cubic-bezier(0.2, 0.8, 0.2, 1) — matches Swift timingCurve / CSS ease used elsewhere.
function ringEase(t) {
  // Unit bezier: P0=(0,0), P1=(0.2,0.8), P2=(0.2,1), P3=(1,1)
  // Solve x(t)=T for t via Newton, then return y(t).
  const cx = 3 * 0.2;
  const bx = 3 * (0.2 - 0.2) - cx;
  const ax = 1 - cx - bx;
  const cy = 3 * 0.8;
  const by = 3 * (1 - 0.8) - cy;
  const ay = 1 - cy - by;
  let u = t;
  for (let i = 0; i < 6; i++) {
    const x = ((ax * u + bx) * u + cx) * u - t;
    const dx = (3 * ax * u + 2 * bx) * u + cx;
    if (Math.abs(dx) < 1e-6) break;
    u -= x / dx;
  }
  return ((ay * u + by) * u + cy) * u;
}

function ringCloseProgress(f) {
  if (f <= RING_CLOSE_START) return 0;
  return Math.min(1, (f - RING_CLOSE_START) / (1 - RING_CLOSE_START));
}

/// Transparent at the arc's start, full colour well before the tip. The arc fades into
/// the track underneath it, which is what the "dissolving tail" reads as. As the ring
/// seals, closeProgress shortens the fade until a solid mask takes over unnoticed.
function ringFadeMask(f) {
  const close = ringCloseProgress(f);
  const end = Math.min(RING_FADE_MAX, 360 * f * RING_FADE_SHARE) * (1 - close);
  if (f >= 1 || end < 0.5) return "none";
  const stop = (deg, a) => `rgba(0,0,0,${a}) ${deg.toFixed(2)}deg`;
  // Head of the arc stays opaque; clear past it so the 360°/0° seam lands on empty track.
  const headDeg = Math.min(360 * f + 0.7, 359.5);
  // A conic gradient's 0deg already points at 12 o'clock and runs clockwise, matching
  // the arc — so no `from` rotation, or the fade lands on the tip instead of the tail.
  return (
    "conic-gradient(at 50% 50%," +
    [
      stop(0, 0),
      stop(end * 0.3, 0.28),
      stop(end * 0.62, 0.72),
      stop(end, 1),
      stop(headDeg, 1),
      stop(Math.min(headDeg + 0.4, 360), 0),
      stop(360, 0),
    ].join(",") +
    ")"
  );
}

/// Paints one frame. The sweep, the tail's fade length and the gloss angle all come off
/// the same fraction, so the gloss tracks the tip instead of jumping ahead of it.
function setRing(fraction) {
  const f = clamp(fraction, 0, 1);
  const arc = $("#ringArc");
  const layer = $("#ringArcLayer");
  const rot = $("#ringHiRot");
  const tip = $("#ringTipRot");
  const close = ringCloseProgress(f);
  const hasArc = f > 0.0001;

  arc.style.strokeDasharray = `${(f * RING_CIRC).toFixed(2)} ${RING_CIRC.toFixed(2)}`;
  const mask = ringFadeMask(f);
  layer.style.maskImage = mask;
  layer.style.webkitMaskImage = mask;

  // Tip stays at full strength through 1 — it lands on the arc's own start and
  // disappears into it. Gloss eases out over closeProgress (.ring-hi keeps its 0.7).
  tip.style.opacity = hasArc ? "1" : "0";
  rot.style.opacity = hasArc ? String(1 - close) : "0";
  tip.style.transform = `rotate(${(360 * f).toFixed(2)}deg)`;
  rot.style.transform = `rotate(${(360 * f - RING_HI_LAG).toFixed(2)}deg)`;
  ringFraction = f;
}

let ringAnim = 0;
let ringFraction = 0;

function renderRing(fraction, animate) {
  const p = ringPalette();
  const screen = $('.screen[data-screen="detail"]');
  screen.style.setProperty("--ring-track", p.track);
  screen.style.setProperty("--ring-head", p.head);
  screen.style.setProperty("--ring-hi", p.hi);

  cancelAnimationFrame(ringAnim);
  const target = clamp(fraction, 0, 1);
  const from = animate ? ringFraction : target;
  if (!animate || Math.abs(target - from) < 0.0005) {
    setRing(target);
    return;
  }

  // Seal-shut (→ 1) gets a longer, softer ease so the closeProgress fade can finish.
  const sealing = target >= 0.999 && from < RING_CLOSE_START;
  const duration = sealing ? RING_CLOSE_MS : RING_MS;
  const t0 = performance.now();
  const step = (now) => {
    const t = Math.min(1, (now - t0) / duration);
    setRing(from + (target - from) * ringEase(t));
    if (t < 1) ringAnim = requestAnimationFrame(step);
    else setRing(target);
  };
  ringAnim = requestAnimationFrame(step);
}

/* ---------- Detail rendering ---------- */
/* Flat-topped fill geometry, per Figma: the fill is inset from the pill edge and
   the gloss sits just below its top edge. */
const PILL_GEO = {
  normal: { h: 44, bottom: 2, innerH: 40, hiLag: 4, minFill: 15 },
  today: { h: 52.8, bottom: 3.8, innerH: 45, hiLag: 4, minFill: 16 },
};

function renderWeekdayPills() {
  const wrap = $("#weekdayDetail");
  wrap.innerHTML = "";
  vm.weekdays.forEach((d) => {
    const isToday = d.state === "today";
    const col = el("div", "wd" + (isToday ? " today" : ""));
    let inner;
    if (d.state === "completed") {
      inner = `<div class="pill completed"><span class="pcheck">${ICONS.checkmark}</span><span class="phi"></span></div>`;
    } else if (d.state === "partial" || isToday) {
      // Figma 1349:5566 — once the whole circle has completed the day, the pill
      // reads like a finished one: full accent fill, white check, and the
      // highlight centred at the top instead of the part-fill gloss.
      const full = clamp(d.fraction, 0, 1) >= 1;
      inner =
        `<div class="pill ${isToday ? "today" : "partial"}${full ? " full" : ""}">` +
        `<div class="fill"></div>` +
        (full
          ? `<span class="pcheck">${ICONS.checkmark}</span><span class="phi"></span>`
          : `<span class="phv"></span>`) +
        `</div>`;
    } else {
      inner = `<div class="pill upcoming"></div>`;
    }
    col.innerHTML = `<div class="wd-label">${d.label}</div>${inner}`;
    wrap.appendChild(col);
  });
  layoutPillFills();
}

function layoutPillFills() {
  const cells = $$("#weekdayDetail .wd");
  vm.weekdays.forEach((d, i) => {
    const fill = $(".fill", cells[i]);
    if (!fill) return;
    const g = d.state === "today" ? PILL_GEO.today : PILL_GEO.normal;
    const h = clamp(d.fraction, 0, 1) * g.innerH;
    fill.style.height = h.toFixed(2) + "px";

    const hi = $(".phv", cells[i]);
    if (!hi) return;
    // Sit the gloss a few px below the fill's flat top, and drop it entirely
    // when the fill is too short to hold it.
    hi.style.top = (g.h - g.bottom - h + g.hiLag).toFixed(2) + "px";
    hi.style.opacity = h >= g.minFill ? "1" : "0";
  });
}

function renderDetail(animateRing) {
  const screen = $('.screen[data-screen="detail"]');
  screen.style.setProperty("--accent", vm.accent);
  screen.style.setProperty("--accent-tint", vm.tint);
  screen.style.setProperty("--accent-partial", blendHex(vm.accent, "#FFFFFF", GLOSS_LIGHTEN));
  screen.classList.toggle("detail-colored", vm.isCompleted);
  // Everyone else's proof stays behind frosted glass until the user has posted their own.
  screen.classList.toggle("detail-unverified", vm.requiresPhoto && !vm.isCompleted);
  // Discover Join preview — HabitDetailView.isJoinLocked
  screen.classList.toggle("detail-join-locked", vm.isJoinLocked);

  $("#detailCircle").textContent = vm.circleName;
  $("#detailName").textContent = vm.title;
  $("#detailMembers").textContent = vm.memberCount;
  $("#detailIcon").src = vm.icon;
  $("#detailDuration").textContent = vm.durationText;
  $("#detailFreq").textContent = vm.frequencyText;
  $("#detailDay").textContent = vm.dayNumber;
  // Figma keeps the emoji in the header title but not in the ring caption.
  $("#ringCircleName").textContent = vm.circleName.replace(/[\p{Extended_Pictographic}\uFE0F]/gu, "").trim();
  // One text node so SF Pro can shape it into a diagonal fraction.
  $("#ringCount").textContent = `${vm.completedCount}/${vm.memberCount}`;

  $("#detailFreqPill").style.display = vm.requiresPhoto ? "" : "none";
  $("#photoHistory").classList.toggle("hidden", !vm.requiresPhoto);
  const chatBtn = $(".chat-btn", screen);
  // Locked Discover preview hides chat entirely; otherwise disable when there's no thread.
  chatBtn.hidden = vm.isJoinLocked;
  chatBtn.disabled = !vm.hasChat;

  // Each shot gets its own clipping box so the locked blur below stays inside its corners
  // instead of dissolving them.
  $("#phScroll").innerHTML = vm.photoHistory
    .map((src) => `<div class="ph-shot"><img src="${src}" alt="" /></div>`)
    .join("");

  renderWeekdayPills();
  updateCta();

  renderRing(vm.progressFraction, animateRing);
}

function updateCta() {
  const btn = $("#ctaBtn");
  $(".cta-label", btn).textContent = vm.ctaTitle;
  $(".cta-ico", btn).innerHTML = ICONS[vm.ctaIcon];
  btn.classList.toggle("done", vm.isCompleted);
  btn.disabled = vm.isCompleted;
}

function openDetail(task, offset, opts = {}) {
  vm = makeViewModel(task, offset, opts);
  ringFraction = 0; // entrance always sweeps from empty
  renderDetail(true);
  renderChat();
  showScreen("detail");
}

/// HabitDetailViewModel.join — clear the Discover gate with a short ease-out.
function joinCircle() {
  if (!vm || !vm.isJoinLocked) return;
  vm.isJoinLocked = false;
  vm.hasChat = vm.requiresPhoto;
  renderDetail(false);
  renderChat();
}

/// HabitDetailViewModel.finishCompletion — updates ring, pills, badge and home list.
function finishCompletion() {
  if (vm.isCompleted) return;
  vm.isCompleted = true;
  vm.completedCount = Math.min(vm.completedCount + 1, vm.memberCount);
  const today = vm.weekdays.find((d) => d.state === "today");
  if (today) today.fraction = vm.progressFraction;
  if (vm.requiresPhoto) vm.chatUnlocked = true;

  // Animate the ring from its current paint to the new fraction (incl. seal-shut).
  renderDetail(true);
  updateChatChrome();

  const task = tasksFor(vm.offset).find((t) => t.id === vm.taskID);
  if (task) completeTaskAndReflow(vm.offset, vm.taskID);
}

/* ---------- Chat rendering ---------- */
/* Members are colour-coded so faces can be told apart without reading a name. Colours are
   taken from a member's slot in the circle's roster rather than hashed from their name, so
   nobody in the same circle can collide and a person keeps one colour across the thread
   and the create flow. Anyone off the roster falls back to a hash. */
const AVATAR_PALETTE = ["#007AFF", "#34C759", "#FF9500", "#AF52DE", "#FF2D55", "#00A5A8", "#5856D6", "#A2845E"];
function avatarColor(seed) {
  const s = seed || "member";
  // Built per call: the roster consts live with the create flow, further down the file.
  const slot = CREATE_MEMBERS.concat(MEMBER_SUGGESTIONS).indexOf(s);
  if (slot >= 0) return AVATAR_PALETTE[slot % AVATAR_PALETTE.length];
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) | 0;
  return AVATAR_PALETTE[Math.abs(h) % AVATAR_PALETTE.length];
}
function hexToRGBA(hex, alpha) {
  const [r, g, b] = hexToRGB(hex);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function bubbleHTML(msg, showTail) {
  if (msg.type === "image") {
    return `<div class="bubble img"><img src="${msg.src}" alt="" /></div>`;
  }
  const cls = "bubble " + (msg.mine ? "mine" : "them") + (showTail ? " tail" : "");
  return `<div class="${cls}">${escapeHTML(msg.text)}</div>`;
}

function renderChat() {
  const scroll = $("#chatScroll");
  scroll.innerHTML = "";
  vm.messages.forEach((msg, i) => {
    const next = vm.messages[i + 1];
    const prev = vm.messages[i - 1];
    const showTail = !next || next.mine !== msg.mine;
    // Only a same-sender run tightens up; a new sender keeps the full gap.
    const grouped = !!prev && prev.mine === msg.mine && prev.avatar === msg.avatar;

    const row = el("div", "msg-row" + (msg.mine ? " mine" : "") + (grouped ? " grouped" : ""));
    if (msg.mine) {
      row.innerHTML = `<div class="spacer"></div>` + bubbleHTML(msg, showTail);
    } else {
      const color = avatarColor(msg.avatar);
      row.innerHTML =
        `<div class="avatar" style="background:${hexToRGBA(color, 0.35)};color:${color}">${ICONS.person}</div>` +
        bubbleHTML(msg, showTail) +
        `<div class="spacer"></div>`;
    }
    scroll.appendChild(row);
  });
  updateChatChrome();
}

/// Header metadata, lock state and composer affordances.
function updateChatChrome() {
  const screen = $('.screen[data-screen="chat"]');
  screen.style.setProperty("--accent", vm.accent);
  screen.style.setProperty("--accent-tint", vm.tint);

  $("#chatIcon").src = vm.icon;
  $("#chatTitle").textContent = vm.title;
  $("#chatMembers").textContent = vm.memberCount;
  $("#chatDuration").textContent = vm.durationText;
  $("#chatFreq").textContent = vm.frequencyText;
  $("#chatDay").textContent = vm.dayNumber;
  $("#chatFreqPill").style.display = vm.requiresPhoto ? "" : "none";
  $("#chatDayBadge").classList.toggle("completed", vm.isCompleted);

  screen.classList.toggle("chat-locked", !vm.chatUnlocked);
  screen.classList.toggle("chat-can-send", vm.canSend);
  screen.classList.toggle("chat-attaching", vm.showAttachmentMenu);

  $("#chatInput").placeholder = vm.needsPhotoToUnlock ? "Post photo to view the circle" : "Text the circle";
}

function sendComposerMessage() {
  if (!vm.canSend) return;
  vm.messages.push({ mine: true, type: "text", text: vm.draft.trim() });
  vm.draft = "";
  vm.showAttachmentMenu = false;
  $("#chatInput").value = "";

  renderChat();
  scrollChatToEnd(true);
}

/// Choosing Camera or Photos is the send — nothing posts before that tap.
function postPhoto(src) {
  const verifying = vm.awaitingVerification || vm.needsPhotoToUnlock;
  vm.awaitingVerification = false;
  vm.showAttachmentMenu = false;
  vm.chatUnlocked = true;
  vm.messages.push({ mine: true, type: "image", src });

  renderChat();
  scrollChatToEnd(true);
  if (verifying) finishCompletion();
}

/// Chats read from the bottom. Anchoring there also lets the thread run up behind
/// the translucent header, so the blur carries all the way to the status bar
/// instead of stopping at a hard edge below the header.
function scrollChatToEnd(smooth) {
  const scroll = $("#chatScroll");
  scroll.scrollTo({ top: scroll.scrollHeight, behavior: smooth ? "smooth" : "auto" });
}

const VERIFICATION_PHOTO = "assets/gym-stairmaster.png";

/* ---------- Photo verification camera ----------
   Figma 1330:7493 -> 1330:7617. "Verify with Photo" on the detail page raises the camera
   sheet; the shutter (or the library link) is what posts, and the thread only opens once
   the shot is on its way. The composer's + picker inside chat is untouched. */
/// A phone camera shows black for a beat while it wakes up, so the feed lands just after
/// the sheet settles rather than being there the instant it opens.
const CAM_WAKE_MS = 620;
let camWakeTimer = 0;

function startPhotoVerification() {
  vm.awaitingVerification = true;
  const screen = $('.screen[data-screen="camera"]');
  $("#camShutter").classList.remove("pressed");
  $("#camShot").src = VERIFICATION_PHOTO;
  clearTimeout(camWakeTimer);
  // The shutter is inert while the viewfinder is black, so no one can post a dead frame.
  screen.classList.add("up", "waking");
  camWakeTimer = setTimeout(() => screen.classList.remove("waking"), CAM_WAKE_MS);
}

function dismissCamera() {
  clearTimeout(camWakeTimer);
  $('.screen[data-screen="camera"]').classList.remove("up");
}

/// Backing out without shooting leaves the habit unverified, so the flag has to go too or
/// the next photo posted from the composer would complete it.
function cancelPhotoVerification() {
  vm.awaitingVerification = false;
  dismissCamera();
}

/// Figma 1330:7617 is the shutter's pressed state, so hold it briefly before the sheet
/// drops away to reveal the thread with the shot posted.
const SHUTTER_MS = 220;

function captureVerificationPhoto() {
  const shutter = $("#camShutter");
  if (shutter.classList.contains("pressed")) return;
  shutter.classList.add("pressed");
  setTimeout(() => {
    shutter.classList.remove("pressed");
    dismissCamera();
    showScreen("chat");
    postPhoto(VERIFICATION_PHOTO);
  }, SHUTTER_MS);
}

function initCamera() {
  $("#camBack").addEventListener("click", cancelPhotoVerification);
  $("#camShutter").addEventListener("click", captureVerificationPhoto);
  // Stands in for the system library picker, which posts the same shot.
  $("#camLibrary").addEventListener("click", captureVerificationPhoto);
}

function initChatControls() {
  $("#composerAdd").addEventListener("click", () => {
    vm.showAttachmentMenu = !vm.showAttachmentMenu;
    updateChatChrome();
  });

  $$("[data-attach]").forEach((btn) => {
    // The web prototype stands in for the camera / library picker.
    btn.addEventListener("click", () => postPhoto(VERIFICATION_PHOTO));
  });

  // Tapping the thread dismisses the picker, which otherwise covers the field.
  $("#chatScroll").addEventListener("click", () => {
    if (!vm.showAttachmentMenu) return;
    vm.showAttachmentMenu = false;
    updateChatChrome();
  });

  const input = $("#chatInput");
  input.addEventListener("input", () => {
    vm.draft = input.value;
    updateChatChrome();
  });
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") sendComposerMessage();
  });
  $("#chatSend").addEventListener("click", sendComposerMessage);
}

/* ==========================================================================
   CREATE HABIT CIRCLE — Figma 1330:7742 / 8032 / 7785 / 7957
   Three input steps plus a success screen, all driven by one state object.
   ========================================================================== */
const CREATE_STEPS = 4;

/// The four cards on step 2, each mapped to the accent palette it unlocks later.
const CREATE_CATEGORIES = [
  { id: "physical", title: "Physical Health", cat: "fitness" },
  { id: "eating", title: "Healthy Eating", cat: "food" },
  { id: "routine", title: "Routine Building", cat: "routine" },
  { id: "misc", title: "Miscellaneous", cat: "misc" },
];

const DURATIONS = ["1 week", "1 month", "3 months", "1 year", "Custom"];

const VISIBILITIES = [
  { id: "restricted", label: "Restricted", icon: "lock", hint: "Only people with access can join the group" },
  { id: "public", label: "Public", icon: "globe", hint: "Anyone can find and join the group" },
];

/// Step 4's avatar row. "You" is the creator and cannot be removed; tapping any other
/// face drops them from the invite, and "Add" pulls in the next suggested person.
const CREATE_MEMBERS = ["You", "Harry", "Zoe", "Bob"];
const MEMBER_SUGGESTIONS = ["Mia", "Leo", "Ada", "Nia"];

const REPEATS = [
  { id: "day", label: "Every Day", unit: "days" },
  { id: "week", label: "Every Week", unit: "weeks" },
  { id: "month", label: "Every Month", unit: "months" },
  { id: "custom", label: "Custom", unit: "days" },
];

const MINUTE_STEP = 5;

let cs = null;

function newCreateState() {
  return {
    step: 1,
    groupName: "",
    goalName: "",
    desc: "",
    category: null,
    duration: "1 month",
    hour: 10,
    minute: 0,
    period: "AM",
    repeat: "day",
    customEvery: 2,
    visibility: "restricted",
    photoVerify: false,
    roster: CREATE_MEMBERS.slice(),
    invited: CREATE_MEMBERS.slice(),
  };
}

function createTimeLabel() {
  return `${cs.hour}:${String(cs.minute).padStart(2, "0")} ${cs.period}`;
}

function createRepeatLabel() {
  const r = REPEATS.find((x) => x.id === cs.repeat);
  if (cs.repeat !== "custom") return r.label;
  return `Every ${cs.customEvery} ${cs.customEvery === 1 ? r.unit.slice(0, -1) : r.unit}`;
}

/// Step 1 needs both names; step 2 needs a category. Everything else has a default.
function createStepValid() {
  if (cs.step === 1) return cs.groupName.trim().length > 0 && cs.goalName.trim().length > 0;
  if (cs.step === 2) return cs.category !== null;
  return true;
}

function renderCreate() {
  const screen = $('.screen[data-screen="create"]');
  const pal = ACCENTS[(CREATE_CATEGORIES.find((c) => c.id === cs.category) || {}).cat] || null;
  screen.style.setProperty("--cat-accent", pal ? pal.accent : "#0EB47F");
  screen.style.setProperty("--cat-tint", pal ? pal.tint : "#E7F7F2");

  $$(".create-step").forEach((s) => s.classList.toggle("on", Number(s.dataset.step) === cs.step));
  // Step 1 closes the flow, so it reads as a dismiss rather than a back step.
  const first = cs.step === 1;
  const back = $("#createBack");
  back.innerHTML = ICONS[first ? "xmark" : "chevron-left"];
  back.setAttribute("aria-label", first ? "Close" : "Back");
  const done = cs.step > CREATE_STEPS;
  $("#createProgress").style.width = `${(Math.min(cs.step, CREATE_STEPS) / CREATE_STEPS) * 100}%`;
  $("#createCta").classList.toggle("done", done);
  $("#createNext").textContent = done ? "Get Started" : "Next";
  $("#createNext").disabled = !done && !createStepValid();

  // Step 2 — category cards
  $("#catGrid").innerHTML = CREATE_CATEGORIES.map(
    (c) =>
      `<button class="cat-card${cs.category === c.id ? " on" : ""}" data-cat="${c.id}">` +
      `<img src="${ACCENTS[c.cat].icon}" alt="" /><span>${c.title}</span></button>`
  ).join("");

  // Step 3 — chips, reminder pills and the toggle
  $("#durationChips").innerHTML = DURATIONS.map(
    (d) => `<button class="cchip${cs.duration === d ? " on" : ""}" data-duration="${d}">${d}</button>`
  ).join("");
  $("#reminderTime").textContent = createTimeLabel();
  $("#reminderEvery").textContent = createRepeatLabel();
  const tog = $("#photoToggle");
  tog.setAttribute("aria-checked", String(cs.photoVerify));

  // Step 4 — visibility select and the member row
  const vis = VISIBILITIES.find((v) => v.id === cs.visibility);
  $("#visibilityIcon").innerHTML = ICONS[vis.icon];
  $("#visibilityLabel").textContent = vis.label;
  $("#visibilityHint").textContent = vis.hint;
  renderMemberRow();

  // Step 5 — the badge borrows the chosen category's icon
  if (pal) $("#cdoneIcon").src = pal.icon;
}

function renderMemberRow() {
  const next = MEMBER_SUGGESTIONS.find((n) => !cs.roster.includes(n));
  const faces = cs.roster
    .map((name) => {
      const off = !cs.invited.includes(name);
      const color = avatarColor(name);
      return (
        `<button class="member${off ? " off" : ""}" data-member="${name}">` +
        `<span class="member-ava" style="background:${hexToRGBA(color, 0.35)};color:${color}">${ICONS.person}</span>` +
        `<span>${name}</span></button>`
      );
    })
    .join("");
  $("#memberRow").innerHTML =
    `<button class="member add" id="memberAdd"${next ? "" : " disabled"}>` +
    `<span class="member-ava">${ICONS.plus}</span><span>Add</span></button>` + faces;
}

function openCreate() {
  cs = newCreateState();
  $("#cGroupName").value = cs.groupName;
  $("#cGoalName").value = cs.goalName;
  $("#cDesc").value = cs.desc;
  $("#createBody").scrollTop = 0;
  closeCreateSheets();
  renderCreate();
  // The screen behind stays put; only the cover slides up over it.
  clearTimeout(_coverTimer);
  $("#tabbar").classList.add("hidden");
  $('.screen[data-screen="create"]').classList.add("up");
}

/// Matches the cover's slide duration, so the tab bar comes back only once the cover
/// has passed it rather than popping in over the animation.
const COVER_MS = 460;
let _coverTimer = 0;

function dismissCreate() {
  closeCreateSheets();
  $('.screen[data-screen="create"]').classList.remove("up");
  clearTimeout(_coverTimer);
  $("#tabbar").classList.add("hidden");
  _coverTimer = setTimeout(() => {
    const name = ($(".screen.active") || {}).dataset?.screen;
    if (name === "home" || name === "discover") $("#tabbar").classList.remove("hidden");
  }, COVER_MS);
}

function createNext() {
  if (cs.step > CREATE_STEPS) {
    // "Get Started" — drop the new circle onto today's list, then reveal it as the
    // cover slides away.
    commitCreatedCircle();
    showScreen("home");
    dismissCreate();
    return;
  }
  if (!createStepValid()) return;
  cs.step += 1;
  $("#createBody").scrollTop = 0;
  renderCreate();
}

function createBack() {
  if (cs.step === 1) {
    dismissCreate();
    return;
  }
  cs.step -= 1;
  $("#createBody").scrollTop = 0;
  renderCreate();
}

/// Adds the circle the user just described to today's task list.
function commitCreatedCircle() {
  const meta = CREATE_CATEGORIES.find((c) => c.id === cs.category) || CREATE_CATEGORIES[0];
  const task = mkTask(cs.goalName.trim() || "New Habit", createTimeLabel(), cs.invited.length, meta.cat, {
    photo: cs.photoVerify,
    circle: cs.groupName.trim(),
    duration: cs.duration === "Custom" ? "1 month" : cs.duration,
    day: 1,
  });
  TASKS_BY_OFFSET["0"].unshift(task);
  selectDay(0);
}

/* ---------- Reminder sheets ---------- */
function openCreateSheet(id) {
  closeCreateSheets();
  $("#csheetScrim").classList.add("on");
  $(id).classList.add("on");
}

function closeCreateSheets() {
  $("#csheetScrim").classList.remove("on");
  $$(".csheet").forEach((s) => s.classList.remove("on"));
}

/* --- Time wheel: 36px rows, whichever row is nearest the centre is selected --- */
const WHEEL_ROW = 36;

function wheelValues(unit) {
  if (unit === "hour") return Array.from({ length: 12 }, (_, i) => String(i + 1));
  if (unit === "min") {
    return Array.from({ length: 60 / MINUTE_STEP }, (_, i) => String(i * MINUTE_STEP).padStart(2, "0"));
  }
  return ["AM", "PM"];
}

function buildWheels() {
  $$(".wheel-col").forEach((col) => {
    col.innerHTML = wheelValues(col.dataset.unit)
      .map((v) => `<div class="wheel-item" data-value="${v}">${v}</div>`)
      .join("");
    let raf = 0;
    col.addEventListener("scroll", () => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(() => markWheel(col));
    });
    col.addEventListener("click", (e) => {
      const item = e.target.closest(".wheel-item");
      if (item) col.scrollTo({ top: item.offsetTop - col.offsetHeight / 2 + WHEEL_ROW / 2, behavior: "smooth" });
    });
  });
}

function markWheel(col) {
  const mid = col.scrollTop + col.offsetHeight / 2;
  let best = null;
  let bestD = Infinity;
  $$(".wheel-item", col).forEach((it) => {
    const d = Math.abs(it.offsetTop + WHEEL_ROW / 2 - mid);
    if (d < bestD) { bestD = d; best = it; }
  });
  $$(".wheel-item", col).forEach((it) => it.classList.toggle("on", it === best));
  return best ? best.dataset.value : null;
}

function scrollWheelTo(col, value) {
  const item = $$(".wheel-item", col).find((it) => it.dataset.value === value);
  if (!item) return;
  col.scrollTop = item.offsetTop - col.offsetHeight / 2 + WHEEL_ROW / 2;
  markWheel(col);
}

function openTimeSheet() {
  openCreateSheet("#timeSheet");
  // Offsets only resolve once the sheet is laid out.
  requestAnimationFrame(() => {
    scrollWheelTo($("#wheelHour"), String(cs.hour));
    scrollWheelTo($("#wheelMin"), String(cs.minute).padStart(2, "0"));
    scrollWheelTo($("#wheelPeriod"), cs.period);
  });
}

function commitTimeSheet() {
  cs.hour = Number(markWheel($("#wheelHour")) || cs.hour);
  cs.minute = Number(markWheel($("#wheelMin")) || cs.minute);
  cs.period = markWheel($("#wheelPeriod")) || cs.period;
  closeCreateSheets();
  renderCreate();
}

function renderVisibilityOptions() {
  $("#visOptions").innerHTML = VISIBILITIES.map(
    (v) =>
      `<button class="opt-row${cs.visibility === v.id ? " on" : ""}" data-visibility="${v.id}">` +
      `<span>${v.label}</span><span class="opt-check">${ICONS.checkmark}</span></button>`
  ).join("");
}

/// "You" anchors the circle, so only the invited guests can be dropped.
function toggleMember(name) {
  if (name === CREATE_MEMBERS[0]) return;
  cs.invited = cs.invited.includes(name)
    ? cs.invited.filter((n) => n !== name)
    : cs.roster.filter((n) => n === name || cs.invited.includes(n));
  renderMemberRow();
}

function addSuggestedMember() {
  const next = MEMBER_SUGGESTIONS.find((n) => !cs.roster.includes(n));
  if (!next) return;
  cs.roster.push(next);
  cs.invited.push(next);
  renderMemberRow();
}

function renderFreqOptions() {
  $("#freqOptions").innerHTML = REPEATS.map(
    (r) =>
      `<button class="opt-row${cs.repeat === r.id ? " on" : ""}" data-repeat="${r.id}">` +
      `<span>${r.label}</span><span class="opt-check">${ICONS.checkmark}</span></button>`
  ).join("");
  $("#customRow").classList.toggle("on", cs.repeat === "custom");
  $("#customUnit").textContent = REPEATS.find((r) => r.id === cs.repeat).unit;
  $("#customEvery").value = cs.customEvery;
}

function initCreateFlow() {
  cs = newCreateState();
  buildWheels();

  $(".fab").addEventListener("click", openCreate);
  $("#createBack").addEventListener("click", createBack);
  $("#createNext").addEventListener("click", createNext);
  $("#createShare").addEventListener("click", () => {
    const btn = $("#createShare");
    btn.textContent = "Link Copied";
    setTimeout(() => (btn.textContent = "Share Link"), 1400);
  });

  $("#cGroupName").addEventListener("input", (e) => { cs.groupName = e.target.value; renderCreate(); });
  $("#cGoalName").addEventListener("input", (e) => { cs.goalName = e.target.value; renderCreate(); });
  $("#cDesc").addEventListener("input", (e) => { cs.desc = e.target.value; });

  // Selections are delegated so the re-rendered chips stay live.
  $("#createBody").addEventListener("click", (e) => {
    const card = e.target.closest("[data-cat]");
    if (card) { cs.category = card.dataset.cat; renderCreate(); return; }
    const dur = e.target.closest("[data-duration]");
    if (dur) { cs.duration = dur.dataset.duration; renderCreate(); return; }
    if (e.target.closest("#memberAdd")) { addSuggestedMember(); return; }
    const member = e.target.closest("[data-member]");
    if (member) toggleMember(member.dataset.member);
  });

  $("#visibilitySelect").addEventListener("click", () => {
    renderVisibilityOptions();
    openCreateSheet("#visSheet");
  });
  $("#visDone").addEventListener("click", () => { closeCreateSheets(); renderCreate(); });
  $("#visOptions").addEventListener("click", (e) => {
    const row = e.target.closest("[data-visibility]");
    if (!row) return;
    cs.visibility = row.dataset.visibility;
    renderVisibilityOptions();
    renderCreate();
  });

  $("#photoToggle").addEventListener("click", () => {
    cs.photoVerify = !cs.photoVerify;
    renderCreate();
  });

  $("#reminderTime").addEventListener("click", openTimeSheet);
  $("#reminderEvery").addEventListener("click", () => {
    renderFreqOptions();
    openCreateSheet("#freqSheet");
  });
  $("#timeDone").addEventListener("click", commitTimeSheet);
  $("#freqDone").addEventListener("click", () => { closeCreateSheets(); renderCreate(); });
  $("#csheetScrim").addEventListener("click", closeCreateSheets);
  $$("[data-sheet-close]").forEach((b) => b.addEventListener("click", closeCreateSheets));

  $("#freqOptions").addEventListener("click", (e) => {
    const row = e.target.closest("[data-repeat]");
    if (!row) return;
    cs.repeat = row.dataset.repeat;
    renderFreqOptions();
  });
  $("#customEvery").addEventListener("input", (e) => {
    cs.customEvery = clamp(Number(e.target.value) || 1, 1, 30);
    $("#customUnit").textContent = REPEATS.find((r) => r.id === cs.repeat).unit;
  });
}

/* ==========================================================================
   WIRE UP
   ========================================================================== */
function init() {
  injectStaticIcons();
  initHome();
  renderDiscover();

  // Seed a view model so the detail / chat screens are renderable before a tap.
  vm = makeViewModel(tasksFor(0)[2], 0);
  renderDetail(false);
  renderChat();
  initChatControls();
  initCamera();
  initCreateFlow();

  $$(".tab").forEach((t) => t.addEventListener("click", () => showScreen(t.dataset.tab)));
  $$("[data-nav]").forEach((b) => b.addEventListener("click", () => showScreen(b.dataset.nav)));

  // Detail back dismisses to Discover when opened from Join, else Home.
  $("#detailBack").addEventListener("click", () => {
    showScreen(vm && vm.openedFrom === "discover" ? "discover" : "home");
  });
  $("#joinViewBtn").addEventListener("click", joinCircle);

  $("#ctaBtn").addEventListener("click", () => {
    if (vm.isCompleted || vm.isJoinLocked) return;
    if (vm.requiresPhoto) {
      startPhotoVerification();
    } else {
      finishCompletion();
    }
  });

  // The locked thread's own way into the camera, so the only way to unlock it isn't a trip
  // back to the detail page.
  $("#lockVerifyBtn").addEventListener("click", startPhotoVerification);

  showScreen("home");
  initGlassCursor();
  fitScreen();
  window.addEventListener("resize", fitScreen);
}

/* ---------- Pointer ----------
   The glass orb from the final presentation prototype (GlassCursor.tsx), scoped to the
   phone rather than the window: it exists only while the pointer is over the screen, so
   it reads as part of the device instead of taking over the page. */
function initGlassCursor() {
  const host = $(".screen-area");
  const orb = $("#glassCursor");
  if (!host || !orb) return;
  // No pointer to follow on touch, and an orb parked in a corner reads as a smudge.
  if (window.matchMedia("(hover: none)").matches) return;

  let frame = 0;
  let x = 0;
  let y = 0;

  const paint = () => {
    orb.style.transform = `translate3d(${x}px, ${y}px, 0) translate(-50%, -50%)`;
    frame = 0;
  };

  const onMove = (event) => {
    const box = host.getBoundingClientRect();
    // fitScreen shrinks the phone on short viewports, so client pixels have to come back
    // to screen points or the orb drifts away from the pointer.
    const scale = box.width / host.offsetWidth || 1;
    x = (event.clientX - box.left) / scale;
    y = (event.clientY - box.top) / scale;
    orb.style.opacity = "1";
    // Coalesced into a frame so a high-Hz pointer can't paint twice in one.
    if (!frame) frame = requestAnimationFrame(paint);
  };
  const hide = () => {
    orb.style.opacity = "0";
  };

  host.classList.add("no-pointer");
  host.addEventListener("pointermove", onMove);
  host.addEventListener("pointerleave", hide);
  window.addEventListener("blur", hide);
}

/* The screen always lays out at a true 402x874pt so every measurement matches
   the simulator; this only shrinks the rendered result so the whole phone stays
   visible top to bottom without scrolling. */
function fitScreen() {
  const fit = $(".device-fit");
  if (!fit) return;
  const margin = window.innerWidth <= 460 ? 0 : 32; // .stage padding
  const scale = Math.min(
    1,
    (window.innerWidth - margin) / PHONE_W,
    (window.innerHeight - margin) / PHONE_H
  );
  fit.style.setProperty("--scale", String(scale));
}

document.addEventListener("DOMContentLoaded", init);
