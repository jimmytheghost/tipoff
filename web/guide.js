const buttons = [...document.querySelectorAll("[data-league]")];
const zone = Intl.DateTimeFormat().resolvedOptions().timeZone;
const dateTitle = document.querySelector("#date");
const leagues = document.querySelector("#leagues");
const dateFormat = new Intl.DateTimeFormat(undefined, { weekday: "short", month: "short", day: "numeric" });
const timeFormat = new Intl.DateTimeFormat(undefined, { timeStyle: "short", timeZone: zone });
const stampFormat = new Intl.DateTimeFormat(undefined, { dateStyle: "medium", timeStyle: "short", timeZone: zone });
let date = new Date();
let active = "all";
let request;

function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text) node.textContent = text;
  if (className) node.className = className;
  return node;
}

function dayKey(day) {
  const month = String(day.getMonth() + 1).padStart(2, "0");
  const number = String(day.getDate()).padStart(2, "0");
  return [day.getFullYear(), month, number].join("-");
}

const sections = new Map(buttons.slice(1).map(button => {
  const id = button.dataset.league;
  const section = element("section", "", "tipoff-league");
  const title = element("h2", button.textContent);
  title.id = `league-${id}`;
  section.setAttribute("aria-labelledby", title.id);
  const status = element("p", "", "tipoff-league-status");
  status.setAttribute("role", "status");
  const results = element("div");
  section.append(title, status, results);
  leagues.append(section);
  return [id, { section, status, results }];
}));

function select(league) {
  active = league;
  buttons.forEach(button => button.setAttribute("aria-pressed", button.dataset.league === active));
  for (const [id, { section }] of sections) section.hidden = active !== "all" && active !== id;
}

// League-native codes differ from ESPN's logo filenames for these clubs.
const logoAliases = {
  nba: { BRK: "bkn", GSW: "gs", NOP: "no", NYK: "ny", SAS: "sa", UTA: "utah", WAS: "wsh" },
  nfl: { JAC: "jax", WAS: "wsh" },
  wnba: { GSV: "gs", LAS: "la", LVA: "lv", NYL: "ny", PHO: "phx", WAS: "wsh" },
  nhl: { LAK: "la", NJD: "nj", SJS: "sj", TBL: "tb", UTA: "utah", WSH: "wsh" },
  mlb: { CWS: "chw", OAK: "ath", WSN: "wsh" },
};

const networkLogos = new Map([
  ["prime video", "https://upload.wikimedia.org/wikipedia/commons/9/90/Prime_Video_logo_%282024%29.svg"],
  ["espn", "https://a.espncdn.com/i/espn/espn_logos/espn_red.png"],
  ["hulu", "https://upload.wikimedia.org/wikipedia/commons/f/f9/Hulu_logo_%282018%29.svg"],
  ["disney+", "https://upload.wikimedia.org/wikipedia/commons/3/3e/Disney%2B_logo.svg"],
  ["nbc", "https://upload.wikimedia.org/wikipedia/commons/0/0b/NBC_logo_2022.svg"],
  ["abc", "https://upload.wikimedia.org/wikipedia/commons/2/2f/ABC-2021-LOGO.svg"],
  ["cbs", "https://upload.wikimedia.org/wikipedia/commons/4/4e/CBS_logo.svg"],
]);

function mark(url, className) {
  const image = element("img", "", className);
  image.alt = "";
  image.referrerPolicy = "no-referrer";
  image.loading = "lazy";
  image.addEventListener("error", () => image.remove(), { once: true });
  image.src = url;
  return image;
}

function team(name, code, league) {
  const line = element("span", "", "tipoff-team");
  if (/^[A-Z0-9]{2,5}$/i.test(code)) {
    const key = code.toUpperCase();
    const slug = logoAliases[league][key] ?? key.toLowerCase();
    const url = league === "mlb" && /^\d+$/.test(key)
      ? `https://www.mlbstatic.com/team-logos/${key}.svg`
      : `https://a.espncdn.com/i/teamlogos/${league}/500/${slug}.png`;
    line.append(mark(url, "tipoff-team-logo"));
  }
  line.append(name);
  return line;
}

function broadcastList(broadcasts) {
  const list = element("ul", "", "tipoff-broadcasts");
  const byName = new Map();
  for (const { name, category } of broadcasts) {
    const key = name.trim().toLowerCase();
    if (!key) continue;
    if (!byName.has(key)) byName.set(key, { name, categories: [] });
    byName.get(key).categories.push(category.toLowerCase());
  }
  for (const [key, { name, categories }] of byName) {
    const item = element("li", "", "tipoff-broadcast");
    const logo = networkLogos.get(key);
    if (key === "league pass" || key === "nba league pass") {
      item.classList.add("tipoff-pass");
      item.append(element("span", "LP", "tipoff-station-tag"));
      item.firstChild.setAttribute("aria-hidden", "true");
    } else if (categories.some(category => category.includes("radio"))) {
      item.append(element("span", "Radio", "tipoff-station-tag"));
    } else if (categories.some(category => /^(home|away|local|regional)\b/.test(category))) {
      item.append(element("span", "Regional", "tipoff-station-tag"));
    }
    if (logo) item.append(mark(logo, "tipoff-network-logo"));
    item.append(element("span", name));
    list.append(item);
  }
  return list.childElementCount ? list : element("p", "Broadcasters not listed", "tipoff-broadcasts");
}

function gameRow(game, league) {
  const row = element("li", "", "tipoff-game");
  const start = game.start ? timeFormat.format(new Date(game.start)) : "Time TBD";
  const matchup = element("p", "", "tipoff-matchup");
  matchup.append(
    team(game.away, game.awayCode, league),
    element("span", " at ", "tipoff-visually-hidden"),
    team(game.home, game.homeCode, league)
  );
  row.append(
    matchup,
    element("p", game.notice ? `${start} · ${game.notice}` : start, "tipoff-start"),
    broadcastList(game.broadcasts)
  );
  if (game.altitude) {
    const details = element("details", "", "tipoff-altitude");
    const altitude = game.altitude;
    details.append(element("summary", "Altitude details"));
    details.append(element("p", altitude.networks.join(", ")));
    if (altitude.pregame) details.append(element("p", `Pregame ${timeFormat.format(new Date(altitude.pregame))}`));
    if (altitude.postgame) details.append(element("p", `Postgame ${timeFormat.format(new Date(altitude.postgame))}`));
    for (const note of altitude.notes) details.append(element("p", note));
    details.append(element("p", `${altitude.saved ? "Saved Altitude data" : "Altitude updated"} ${stampFormat.format(new Date(altitude.fetchedAt))}`, "tipoff-meta"));
    row.append(details);
  }
  return row;
}

async function loadLeague(id, day, signal) {
  const { status, results } = sections.get(id);
  status.textContent = "Loading schedule…";
  results.replaceChildren();
  try {
    const params = new URLSearchParams({ sport: id, day, zone });
    const response = await fetch(`/tip-off/schedule?${params}`, { signal });
    if (!response.ok) throw new Error("Schedule request failed");
    const { snapshot, saved } = await response.json();
    if (signal.aborted) return;
    if (!snapshot || snapshot.day !== day || snapshot.timeZone !== zone || (snapshot.guide ?? "nba") !== id) {
      throw new Error("Schedule unavailable");
    }
    const count = snapshot.games.length;
    const summary = count === 0 ? "No games scheduled" : `${count} ${count === 1 ? "game" : "games"}`;
    const updated = stampFormat.format(new Date(snapshot.fetchedAt));
    status.textContent = `${summary} · ${snapshot.source} · ${saved ? "Refresh failed, saved" : "Updated"} ${updated}`;
    if (count) {
      const list = element("ul", "", "tipoff-games");
      list.append(...snapshot.games.map(game => gameRow(game, id)));
      results.append(list);
    }
    if (snapshot.altitudeWarning) results.append(element("p", snapshot.altitudeWarning, "tipoff-meta"));
  } catch {
    if (signal.aborted) return;
    results.replaceChildren();
    status.textContent = "Schedule unavailable.";
  }
}

function loadDay() {
  request?.abort();
  request = new AbortController();
  const key = dayKey(date);
  dateTitle.textContent = dayKey(new Date()) === key ? `Today · ${dateFormat.format(date)}` : dateFormat.format(date);
  for (const id of sections.keys()) loadLeague(id, key, request.signal);
}

function moveDay(offset) {
  date = new Date(date.getFullYear(), date.getMonth(), date.getDate() + offset, 12);
  loadDay();
}

document.querySelector("#zone").textContent = `Times shown in ${zone.replaceAll("_", " ")}.`;
buttons.forEach(button => button.addEventListener("click", () => select(button.dataset.league)));
document.querySelector("#previous").addEventListener("click", () => moveDay(-1));
document.querySelector("#next").addEventListener("click", () => moveDay(1));
document.querySelector("#today").addEventListener("click", () => {
  date = new Date();
  loadDay();
});
loadDay();
