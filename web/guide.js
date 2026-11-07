const buttons = [...document.querySelectorAll("[data-league]")];
const zone = Intl.DateTimeFormat().resolvedOptions().timeZone;
const dateTitle = document.querySelector("#date");
const leagues = document.querySelector("#leagues");
const followedLeagues = document.querySelector("#followed-leagues");
const following = document.querySelector("#following");
const highlightsTitle = document.querySelector("#highlights-title");
const nationalTitle = document.querySelector("#national-title");
const followedTeams = new Map([
  ["nba", { name: "Nuggets", codes: ["DEN"] }],
  ["nfl", { name: "Broncos", codes: ["DEN"] }],
  ["nhl", { name: "Avalanche", codes: ["COL"] }],
  ["mlb", { name: "Rockies", codes: ["115", "COL"] }],
]);
const nationalLeagues = document.querySelector("#national-leagues");
const nationalStatus = document.querySelector("#national-status");
const scheduleStatuses = document.querySelector("#schedule-statuses");
const scheduleStatusSummary = document.querySelector("#schedule-status-summary");
const sourceStates = new Map();
const scheduleStatusContainer = scheduleStatuses.closest("details");
document.addEventListener("pointerdown", event => {
  if (scheduleStatusContainer.open && !scheduleStatusContainer.contains(event.target)) scheduleStatusContainer.open = false;
});
document.addEventListener("keydown", event => {
  if (event.key === "Escape" && scheduleStatusContainer.open) {
    scheduleStatusContainer.open = false;
    scheduleStatusContainer.querySelector("summary").focus();
  }
});

function scheduleStatusText(states, completedAt, total = 5) {
  const loaded = states.filter(value => value === "updated" || value === "saved").length;
  const errors = states.filter(value => value === "unavailable").length;
  const pending = total - loaded - errors;
  if (!pending && !errors) return `All schedules loaded ${completedAt}`;
  return [
    `${loaded} loaded`,
    errors ? `${errors} ${errors === 1 ? "error" : "errors"}` : "",
    pending ? `${pending} loading` : "",
  ].filter(Boolean).join(" - ");
}

function updateSourceStatus(id, node, state, text) {
  sourceStates.set(id, state);
  node.textContent = text;
  const completedAt = new Date();
  const stamp = stampFormat.format(completedAt);
  const message = scheduleStatusText([...sourceStates.values()], stamp);
  if (message === `All schedules loaded ${stamp}`) {
    const timestamp = element("time", stamp, "tipoff-status-loaded-time");
    timestamp.dateTime = completedAt.toISOString();
    scheduleStatusSummary.replaceChildren(
      element("span", "All schedules loaded", "tipoff-status-loaded-label"),
      document.createTextNode(" "), timestamp);
  } else {
    scheduleStatusSummary.textContent = message;
  }
}
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

function dateFromDayKey(value) {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) return null;
  const selected = new Date(0);
  selected.setFullYear(Number(match[1]), Number(match[2]) - 1, Number(match[3]));
  selected.setHours(12, 0, 0, 0);
  return dayKey(selected) === value ? selected : null;
}

function calendarDaysForMonth(day) {
  const first = new Date(day.getFullYear(), day.getMonth(), 1, 12);
  return Array.from({ length: 42 }, (_, index) =>
    new Date(first.getFullYear(), first.getMonth(), 1 - first.getDay() + index, 12));
}

function shiftCalendarMonth(day, offset) {
  const month = new Date(day.getFullYear(), day.getMonth() + offset, 1, 12);
  const last = new Date(month.getFullYear(), month.getMonth() + 1, 0, 12).getDate();
  return new Date(month.getFullYear(), month.getMonth(), Math.min(day.getDate(), last), 12);
}

function leagueHeader(tag, id, label) {
  const title = element(tag, "", "tipoff-league-header");
  title.id = id;
  const name = element("span", label, "tipoff-header-name");
  name.id = `${id}-name`;
  const gameCount = element("span", "", "tipoff-league-count");
  const identity = element("span", "", "tipoff-header-identity");
  identity.append(name, gameCount);
  title.append(identity);
  return { title, name, gameCount };
}

function summaryGroup(parent, id, label) {
  const group = element("section", "", "tipoff-league");
  const { title, name, gameCount } = leagueHeader("h3", id, label);
  group.setAttribute("aria-labelledby", name.id);
  const games = element("ul", "", "tipoff-games");
  group.append(title, games);
  group.hidden = true;
  parent.append(group);
  return { group, title, games, gameCount };
}

function resetSummary({ group, title, games }) {
  title.querySelector(".tipoff-national-marker")?.remove();
  group.hidden = true;
  games.replaceChildren();
}

const sections = new Map(buttons.slice(1).map(button => {
  const id = button.dataset.league;
  const section = element("section", "", "tipoff-league");
  const { title, name, gameCount } = leagueHeader("h2", `league-${id}`, button.textContent);
  section.setAttribute("aria-labelledby", name.id);
  const results = element("div");
  section.append(title, results);
  leagues.append(section);
  const national = summaryGroup(nationalLeagues, `national-${id}`, button.textContent);
  const followedTeam = followedTeams.get(id);
  const followed = followedTeam && summaryGroup(followedLeagues, `followed-${id}`, followedTeam.name);
  const status = element("dd");
  const sourceRow = element("div");
  sourceRow.append(element("dt", button.textContent), status);
  scheduleStatuses.append(sourceRow);
  return [id, { section, title, gameCount, status, results, national, followed }];
}));

function select(league) {
  active = league;
  buttons.forEach(button => button.setAttribute("aria-pressed", button.dataset.league === active));
  for (const [id, { section }] of sections) {
    section.hidden = active !== "all" && id !== active;
  }
}

// League-native codes differ from ESPN's logo filenames for these clubs.
const logoAliases = {
  nba: { BRK: "bkn", GSW: "gs", NOP: "no", NYK: "ny", SAS: "sa", UTA: "utah", WAS: "wsh" },
  nfl: { JAC: "jax", WAS: "wsh" },
  wnba: { GSV: "gs", LAS: "la", LVA: "lv", NYL: "ny", PHO: "phx", WAS: "wsh" },
  nhl: { LAK: "la", NJD: "nj", SJS: "sj", TBL: "tb", UTA: "utah", WSH: "wsh" },
  mlb: { CWS: "chw", OAK: "ath", WSN: "wsh" },
};

// MLB StatsAPI IDs matched to ESPN team metadata on November 7, 2026.
// https://statsapi.mlb.com/api/v1/teams?sportId=1
const mlbLogoCodes = {
  108: "laa", 109: "ari", 110: "bal", 111: "bos", 112: "chc", 113: "cin",
  114: "cle", 115: "col", 116: "det", 117: "hou", 118: "kc", 119: "lad",
  120: "wsh", 121: "nym", 133: "ath", 134: "pit", 135: "sd", 136: "sea",
  137: "sf", 138: "stl", 139: "tb", 140: "tex", 141: "tor", 142: "min",
  143: "phi", 144: "atl", 145: "chw", 146: "mia", 147: "nyy", 158: "mil",
};

function teamLogoSources(code, league) {
  if (typeof code !== "string" || !/^[A-Z0-9]{2,5}$/i.test(code) || !logoAliases[league]) return [];
  const key = code.toUpperCase();
  const numericMLB = league === "mlb" && /^\d+$/.test(key);
  const original = numericMLB ? `https://www.mlbstatic.com/team-logos/${key}.svg` : null;
  const slug = numericMLB ? mlbLogoCodes[key] : logoAliases[league][key] ?? key.toLowerCase();
  if (!slug) return original ? [original] : [];
  // ESPN lists these as rel=["full", "dark"] in its public team metadata.
  return [
    `https://a.espncdn.com/i/teamlogos/${league}/500-dark/${slug}.png`,
    `https://a.espncdn.com/i/teamlogos/${league}/500/${slug}.png`,
    ...(original ? [original] : []),
  ];
}

const networkLogos = new Map([
  ["altitude 2", "https://cdn.tvpassport.com/image/station/240x135/v2/s56256_h15_ab.png"],
  ["alt2", "https://cdn.tvpassport.com/image/station/240x135/v2/s56256_h15_ab.png"],
  ["altitude+", "https://altitude.asset.viewlift.com/images/brand/2024/09/27/Altitude-Plus-1727459839724.png"],
  ["nba tv", "https://upload.wikimedia.org/wikipedia/en/d/d2/NBA_TV.svg"],
  ["tnt", "https://upload.wikimedia.org/wikipedia/commons/2/24/TNT_Logo_2016.svg"],
  ["hbo max", "https://upload.wikimedia.org/wikipedia/commons/7/7e/HBO_Max_May_2025_%28Horizontal%29.svg"],
  ["trutv", "https://upload.wikimedia.org/wikipedia/commons/3/36/TruTV_2014.svg"],
  ["altitude", "https://upload.wikimedia.org/wikipedia/en/e/e2/Altitude_Sports_logo.svg"],
  ["alt", "https://upload.wikimedia.org/wikipedia/en/e/e2/Altitude_Sports_logo.svg"],
  ["peacock", "https://upload.wikimedia.org/wikipedia/commons/2/20/NBCUniversal_Peacock_Logo_%282026%29.svg"],
  ["fox", "https://upload.wikimedia.org/wikipedia/commons/f/f7/FOX_wordmark-black.svg"],
  ["prime video", "https://upload.wikimedia.org/wikipedia/commons/9/90/Prime_Video_logo_%282024%29.svg"],
  ["espn", "https://upload.wikimedia.org/wikipedia/commons/2/2f/ESPN_wordmark.svg"],
  ["espn+", "https://upload.wikimedia.org/wikipedia/commons/8/80/ESPN_Plus.svg"],
  ["hulu", "https://upload.wikimedia.org/wikipedia/commons/f/f9/Hulu_logo_%282018%29.svg"],
  ["disney+", "https://upload.wikimedia.org/wikipedia/commons/7/77/Disney_Plus_logo.svg"],
  ["nbc", "https://upload.wikimedia.org/wikipedia/commons/9/90/NBC_2023_white_logo.svg"],
  ["nbcsn", "https://upload.wikimedia.org/wikipedia/commons/3/36/NBCSN_Logo_2025.svg"],
  ["nbc sports network", "https://upload.wikimedia.org/wikipedia/commons/3/36/NBCSN_Logo_2025.svg"],
  ["abc", "https://upload.wikimedia.org/wikipedia/commons/2/2f/ABC-2021-LOGO.svg"],
  ["cbs", "https://upload.wikimedia.org/wikipedia/commons/4/4e/CBS_logo.svg"],
]);

function mark(url, className, fallbackUrls = []) {
  const image = element("img", "", className);
  image.alt = "";
  image.referrerPolicy = "no-referrer";
  image.loading = "lazy";
  let fallback = 0;
  image.addEventListener("error", () => {
    if (fallback < fallbackUrls.length) image.src = fallbackUrls[fallback++];
    else image.remove();
  });
  image.src = url;
  return image;
}

// Presentation only: retain source team names in snapshots and hover titles.
const teamLocations = [
  "Anaheim", "Arizona", "Atlanta", "Baltimore", "Boston", "Brooklyn", "Buffalo",
  "Calgary", "Carolina", "Charlotte", "Chicago", "Cincinnati", "Cleveland",
  "Colorado", "Columbus", "Connecticut", "Dallas", "Denver", "Detroit", "Edmonton",
  "Florida", "Golden State", "Green Bay", "Houston", "Indiana", "Indianapolis",
  "Jacksonville", "Kansas City", "Las Vegas", "Los Angeles", "LA", "Memphis",
  "Miami", "Milwaukee", "Minnesota", "Montréal", "Montreal", "Nashville",
  "New England", "New Jersey", "New Orleans", "New York", "Oklahoma City",
  "Orlando", "Ottawa", "Philadelphia", "Phoenix", "Pittsburgh", "Portland",
  "Sacramento", "Salt Lake City", "San Antonio", "San Diego", "San Francisco",
  "San Jose", "Seattle", "St. Louis", "St Louis", "Tampa Bay", "Tennessee",
  "Texas", "Toronto", "Utah", "Vancouver", "Vegas", "Washington", "Winnipeg",
].sort((a, b) => b.length - a.length);

function shortTeamName(name) {
  const trimmed = name.trim();
  const location = teamLocations.find(location => trimmed.toLowerCase().startsWith(`${location.toLowerCase()} `));
  return location ? trimmed.slice(location.length).trim() || trimmed : trimmed;
}

// NBA.com game cards sometimes omit teamCity. Display names checked against
// https://www.nba.com/teams on November 7, 2026; stored source names stay intact.
const nbaFullNames = new Map([
  "Atlanta Hawks", "Boston Celtics", "Brooklyn Nets", "Charlotte Hornets",
  "Chicago Bulls", "Cleveland Cavaliers", "Dallas Mavericks", "Denver Nuggets",
  "Detroit Pistons", "Golden State Warriors", "Houston Rockets", "Indiana Pacers",
  "LA Clippers", "Los Angeles Lakers", "Memphis Grizzlies", "Miami Heat",
  "Milwaukee Bucks", "Minnesota Timberwolves", "New Orleans Pelicans", "New York Knicks",
  "Oklahoma City Thunder", "Orlando Magic", "Philadelphia 76ers", "Phoenix Suns",
  "Portland Trail Blazers", "Sacramento Kings", "San Antonio Spurs", "Toronto Raptors",
  "Utah Jazz", "Washington Wizards",
].map(name => [shortTeamName(name).toLowerCase(), name]));

function fullTeamName(name, league) {
  return league === "nba" ? nbaFullNames.get(name.trim().toLowerCase()) ?? name : name;
}

function team(name, code, league) {
  const line = element("span", "", "tipoff-team");
  const [url, ...fallbacks] = teamLogoSources(code, league);
  if (url) {
    const logo = mark(url, "tipoff-team-logo", fallbacks);
    const refit = () => fitMatchupNames(line.closest(".tipoff-matchup"));
    logo.addEventListener("load", refit);
    logo.addEventListener("error", refit);
    line.append(logo);
  }
  const displayName = fullTeamName(name, league);
  line.setAttribute("role", "img");
  line.setAttribute("aria-label", displayName);
  line.title = displayName;
  const label = element("span", "", "tipoff-team-name");
  label.setAttribute("aria-hidden", "true");
  label.append(element("span", displayName, "tipoff-team-full"), element("span", shortTeamName(displayName), "tipoff-team-short"));
  label.title = displayName;
  line.append(label);
  return line;
}

function fitMatchupNames(matchup) {
  if (!matchup?.isConnected || !matchup.getBoundingClientRect().width) return;
  // Measure name layouts with their normal logo size before enlarging logo-only rows.
  matchup.classList.remove("tipoff-matchup-logos");
  const gap = node => Number.parseFloat(getComputedStyle(node).columnGap) || 0;
  const teams = [...matchup.querySelectorAll(".tipoff-team")];
  const required = variant => teams.reduce((total, node) => {
    const logo = node.querySelector(".tipoff-team-logo");
    return total + node.querySelector(`.tipoff-team-${variant}`).getBoundingClientRect().width +
      (logo ? logo.getBoundingClientRect().width + gap(node) : 0);
  }, matchup.querySelector(".tipoff-matchup-separator").getBoundingClientRect().width +
    gap(matchup) + gap(matchup.querySelector(".tipoff-matchup-home")));
  const available = Math.floor(matchup.getBoundingClientRect().width);
  const short = Math.ceil(required("full")) > available;
  const logosReady = teams.length === 2 && teams.every(node => {
    const logo = node.querySelector(".tipoff-team-logo");
    return logo?.complete && logo.naturalWidth > 0;
  });
  matchup.classList.toggle("tipoff-matchup-short", short);
  matchup.classList.toggle("tipoff-matchup-logos", short && Math.ceil(required("short")) > available && logosReady);
}

const matchupSizes = new ResizeObserver(entries => {
  for (const { target } of entries) fitMatchupNames(target);
});
// Font metrics may change without changing the grid column width.
document.fonts.ready.then(() => document.querySelectorAll(".tipoff-matchup").forEach(fitMatchupNames));
document.fonts.addEventListener("loadingdone", () => document.querySelectorAll(".tipoff-matchup").forEach(fitMatchupNames));

function broadcastList(broadcasts, { showMarketLabels = true } = {}) {
  const list = element("ul", "", "tipoff-broadcasts");
  const byName = new Map();
  for (const { name, category } of broadcasts) {
    const key = name.trim().toLowerCase();
    if (!key || category.toLowerCase().includes("radio")) continue;
    if (!byName.has(key)) byName.set(key, { name, categories: [] });
    byName.get(key).categories.push(category.toLowerCase());
  }
  for (const [key, { name, categories }] of byName) {
    const item = element("li", "", "tipoff-broadcast");
    const logoKey = key.replace(/[*^]+$/, "");
    const logo = networkLogos.get(logoKey);
    if (key === "league pass" || key === "nba league pass") {
      item.classList.add("tipoff-pass");
      item.append(element("span", "LP", "tipoff-station-tag"));
      item.firstChild.setAttribute("aria-hidden", "true");
    } else if (showMarketLabels && categories.some(category => /^(home|away|local|regional)\b/.test(category))) {
      item.append(element("span", "Regional", "tipoff-station-tag"));
    }
    const label = element("span", name);
    if (logo) {
      const image = mark(logo, "tipoff-network-logo");
      if (["nbcsn", "nbc sports network", "espn", "espn+", "cbs", "fox", "peacock", "tnt", "hbo max", "trutv", "altitude", "alt", "altitude 2", "alt2"].includes(logoKey)) image.classList.add("tipoff-network-logo-light");
      image.addEventListener("load", () => {
        image.style.setProperty("--network-ratio", image.naturalWidth / image.naturalHeight);
        label.classList.add("tipoff-visually-hidden");
      }, { once: true });
      item.append(image);
    }
    item.append(label);
    list.append(item);
  }
  return list.childElementCount ? list : element("p", "Broadcasters not listed", "tipoff-broadcasts");
}

const nonFeaturedNetworks = new Set([
  "nflnet", "nflnetwork", "nfln", "nbatv", "nhln", "nhlnetwork", "mlbtv", "nhlcenterice", "centerice",
  "nflsundayticket", "sundayticket", "mlbextrainnings", "extrainnings",
]);

function isNationalBroadcast({ name, category }, league) {
  const channel = name.toLowerCase().replace(/[^a-z0-9+]/g, "");
  const market = category.trim().toLowerCase();
  // Only the NBA feed uses Streaming for national OTT.
  return channel !== "" && !channel.includes("leaguepass") && !nonFeaturedNetworks.has(channel) &&
    (market === "national" || (league === "nba" && market === "streaming"));
}

function compactBroadcasts(broadcasts, league) {
  const video = broadcasts.filter(({ name, category }) => name.trim() && !category.toLowerCase().includes("radio"));
  const national = video.filter(broadcast => isNationalBroadcast(broadcast, league));
  if (national.length) return national;
  const isAltitude = ({ name }) => ["alt", "altitude", "alt2", "altitude2"]
    .includes(name.toLowerCase().replace(/[^a-z0-9]/g, ""));
  const altitude = video.find(broadcast => broadcast.category === "Altitude guide" && isAltitude(broadcast))
    ?? video.find(isAltitude);
  return altitude ? [altitude] : video.slice(0, 1);
}

function gameRow(game, league, broadcasts, highlight, { collapseBroadcasts = false, compact = false } = {}) {
  const row = element("li", "", "tipoff-game");
  if (highlight) row.classList.add(highlight);
  const start = game.start ? timeFormat.format(new Date(game.start)) : "Time TBD";
  const matchup = element("span", "", "tipoff-matchup");
  const home = element("span", "", "tipoff-matchup-home");
  home.append(element("span", " @ ", "tipoff-matchup-separator"), team(game.home, game.homeCode, league));
  matchup.append(team(game.away, game.awayCode, league), home);
  const nationalBroadcasts = broadcasts.filter(broadcast => isNationalBroadcast(broadcast, league));
  const leadingBroadcasts = compact ? compactBroadcasts(broadcasts, league) : nationalBroadcasts;
  const visibleBroadcasts = broadcasts.filter(broadcast => broadcast.name.trim() && !broadcast.category.toLowerCase().includes("radio"));
  const hasCompactDetails = compact && (game.altitude || visibleBroadcasts.length > leadingBroadcasts.length ||
    visibleBroadcasts.some(broadcast => /^(home|away|local|regional)\b/i.test(broadcast.category)));
  let heading = row;
  let content = row;
  if (collapseBroadcasts || hasCompactDetails) {
    content = element("details", "", hasCompactDetails ? "tipoff-followed-details" : "tipoff-game-details");
    heading = element("summary", "", "tipoff-game-toggle");
    if (hasCompactDetails) heading.title = "Broadcast details";
    content.append(heading);
    row.append(content);
  }
  if (leadingBroadcasts.length || compact) {
    heading.classList.add("tipoff-game-inline");
    const logos = leadingBroadcasts.length ? broadcastList(leadingBroadcasts, { showMarketLabels: !compact })
      : element("span", "—", "tipoff-meta");
    if (!leadingBroadcasts.length) logos.setAttribute("aria-label", "Broadcasters not listed");
    logos.classList.add("tipoff-inline-broadcasts");
    heading.append(logos);
  }
  heading.append(matchup, element("span", start, "tipoff-start"));
  if (game.notice) heading.append(element("span", game.notice, "tipoff-game-notice"));
  if (hasCompactDetails) {
    const body = element("div", "", "tipoff-followed-body");
    body.append(element("h4", "Broadcast listings"), broadcastList(broadcasts));
    content.append(body);
    content = body;
  } else if (!compact) {
    const nationalNames = new Set(nationalBroadcasts.map(broadcast => broadcast.name.trim().toLowerCase()));
    const otherBroadcasts = broadcasts.filter(broadcast =>
      !nationalNames.has(broadcast.name.trim().toLowerCase()) && !broadcast.category.toLowerCase().includes("radio"));
    if (!nationalBroadcasts.length || otherBroadcasts.length) content.append(broadcastList(otherBroadcasts));
  }
  if (game.altitude && broadcasts === game.broadcasts) {
    const details = element(compact ? "section" : "details", "", "tipoff-altitude");
    const altitude = game.altitude;
    details.append(element(compact ? "h4" : "summary", "Altitude details"));
    details.append(element("p", altitude.networks.join(", ")));
    if (altitude.pregame) details.append(element("p", `Pregame ${timeFormat.format(new Date(altitude.pregame))}`));
    if (altitude.postgame) details.append(element("p", `Postgame ${timeFormat.format(new Date(altitude.postgame))}`));
    for (const note of altitude.notes) details.append(element("p", note));
    details.append(element("p", `${altitude.saved ? "Saved Altitude data" : "Altitude updated"} ${stampFormat.format(new Date(altitude.fetchedAt))}`, "tipoff-meta"));
    content.append(details);
  }
  matchupSizes.observe(matchup);
  return row;
}

function schedulePause(signal) {
  return new Promise((resolve, reject) => {
    const abort = () => {
      clearTimeout(timer);
      reject(new DOMException("Schedule changed", "AbortError"));
    };
    const timer = setTimeout(() => {
      signal.removeEventListener("abort", abort);
      resolve();
    }, 1500);
    if (signal.aborted) abort();
    else signal.addEventListener("abort", abort, { once: true });
  });
}

async function fetchSchedule(params, signal) {
  const deadline = Date.now() + 95000;
  do {
    const attempt = new AbortController();
    const abort = () => attempt.abort();
    signal.addEventListener("abort", abort, { once: true });
    const timer = setTimeout(abort, 8000);
    let response;
    let data;
    try {
      if (signal.aborted) attempt.abort();
      response = await fetch(`/tipoff/schedule?${params}`, { signal: attempt.signal });
      data = await response.json();
    } finally {
      clearTimeout(timer);
      signal.removeEventListener("abort", abort);
    }
    if (response.status === 202 && data.refreshing) {
      await schedulePause(signal);
      continue;
    }
    if (!response.ok) throw new Error("Schedule request failed");
    return data;
  } while (!signal.aborted && Date.now() < deadline);
  throw new Error("Schedule refresh timed out");
}

function updateHighlightHeadings() {
  const hasFollowedGames = Boolean(followedLeagues.querySelector("section:not([hidden])"));
  const hasNationalGames = Boolean(nationalLeagues.querySelector("section:not([hidden])"));
  following.hidden = !hasFollowedGames;
  highlightsTitle.textContent = hasFollowedGames ? "Following" : "National Broadcasts";
  highlightsTitle.hidden = !hasFollowedGames && !hasNationalGames;
  nationalTitle.hidden = !hasFollowedGames || !hasNationalGames;
}

async function loadLeague(id, day, signal) {
  const { section, title, gameCount, status, results, national, followed } = sections.get(id);
  section.replaceChildren(title, results);
  gameCount.textContent = "";
  const summaries = followed ? [national, followed] : [national];
  const followedTeam = followedTeams.get(id);
  updateSourceStatus(id, status, "loading", "Loading schedule…");
  results.replaceChildren();
  try {
    const params = new URLSearchParams({ sport: id, day, zone });
    const { snapshot, saved } = await fetchSchedule(params, signal);
    if (signal.aborted) return;
    if (!snapshot || snapshot.day !== day || snapshot.timeZone !== zone || (snapshot.guide ?? "nba") !== id) {
      throw new Error("Schedule unavailable");
    }
    const count = snapshot.games.length;
    gameCount.textContent = `${count} ${count === 1 ? "game" : "games"}`;
    const updated = stampFormat.format(new Date(snapshot.fetchedAt));
    updateSourceStatus(id, status, saved ? "saved" : "updated",
      `${snapshot.source} · ${saved ? "Saved listings" : "Updated"} ${updated}${snapshot.altitudeWarning ? ` · ${snapshot.altitudeWarning}` : ""}`);
    if (count) {
      const list = element("ul", "", "tipoff-games");
      for (const game of snapshot.games) {
        const nationalBroadcasts = game.broadcasts.filter(broadcast => isNationalBroadcast(broadcast, id));
        const isFollowed = followedTeam && [game.awayCode, game.homeCode]
          .some(code => followedTeam.codes.includes(code.toUpperCase()));
        let highlight;
        if (isFollowed) highlight = "tipoff-game-followed";
        else if (nationalBroadcasts.length) highlight = "tipoff-game-national";
        list.append(gameRow(game, id, game.broadcasts, highlight, { collapseBroadcasts: !highlight }));
        if (isFollowed) {
          followed.games.append(gameRow(game, id, game.broadcasts, undefined, { compact: true }));
          if (nationalBroadcasts.length && !followed.title.querySelector(".tipoff-national-marker")) {
            followed.title.querySelector(".tipoff-header-name").append(element("span", "National", "tipoff-national-marker"));
          }
        } else if (nationalBroadcasts.length) {
          national.games.append(gameRow(game, id, nationalBroadcasts));
        }
      }
      for (const { group, games, gameCount } of summaries) {
        const count = games.childElementCount;
        gameCount.textContent = `${count} ${count === 1 ? "game" : "games"}`;
        group.hidden = !count;
      }
      results.append(list);
    }
    if (count === 0) {
      results.append(element("p", "No games scheduled.", "tipoff-meta"));
      const details = element("details", "", "tipoff-inactive-league");
      const toggle = element("summary");
      toggle.append(title);
      details.append(toggle, results);
      section.replaceChildren(details);
    }
    updateHighlightHeadings();
    return true;
  } catch {
    if (signal.aborted) return;
    results.replaceChildren();
    summaries.forEach(resetSummary);
    gameCount.textContent = "";
    updateSourceStatus(id, status, "unavailable", "Schedule unavailable.");
    updateHighlightHeadings();
    return false;
  }
}

async function loadDay() {
  matchupSizes.disconnect();
  request?.abort();
  request = new AbortController();
  const key = dayKey(date);
  dateTitle.setAttribute("aria-label", `Choose schedule date, ${date.toLocaleDateString(undefined, { dateStyle: "full" })}`);
  dateTitle.replaceChildren();
  if (dayKey(new Date()) === key) dateTitle.append(element("span", "Today", "tipoff-date-today"));
  dateTitle.append(element("span", dateFormat.format(date), "tipoff-date-label"));
  const { signal } = request;
  following.hidden = true;
  highlightsTitle.textContent = "National Broadcasts";
  highlightsTitle.hidden = true;
  nationalTitle.hidden = true;
  sourceStates.clear();
  nationalStatus.textContent = "";
  for (const { section, national, followed } of sections.values()) {
    leagues.append(section);
    resetSummary(national);
    if (followed) resetSummary(followed);
  }
  const ids = [...sections.keys()];
  const loaded = await Promise.all(ids.map(id => loadLeague(id, key, signal)));
  if (signal.aborted) return;
  for (const { section } of sections.values()) {
    if (section.firstElementChild.matches(".tipoff-inactive-league")) leagues.append(section);
  }
  updateHighlightHeadings();
  if (loaded.some(result => !result)) {
    nationalStatus.textContent = "";
  } else {
    const hasNationalGames = nationalLeagues.querySelector("section:not([hidden])") ||
      followedLeagues.querySelector(".tipoff-national-marker");
    nationalStatus.textContent = hasNationalGames ? "" : "No national broadcasts listed.";
  }
}

function moveDay(offset) {
  date = new Date(date.getFullYear(), date.getMonth(), date.getDate() + offset, 12);
  loadDay();
}

// Move the same controls so resizing retains the selected date and listeners.
const dateControls = document.querySelector(".tipoff-date");
const desktopLayout = window.matchMedia("(min-width: 64rem)");
function placeDateControls() {
  const focused = document.activeElement;
  const calendar = dateControls.querySelector("#date-picker");
  if (calendar.matches(":popover-open")) calendar.hidePopover();
  dateTitle.setAttribute("aria-expanded", "false");
  if (desktopLayout.matches) document.querySelector("#header-date").append(dateControls);
  else highlightsTitle.before(dateControls);
  if (calendar.contains(focused)) dateTitle.focus({ preventScroll: true });
  else if (dateControls.contains(focused)) focused.focus({ preventScroll: true });
}
desktopLayout.addEventListener("change", placeDateControls);
placeDateControls();

const datePicker = document.querySelector("#date-picker");
const calendarGrid = document.querySelector("#calendar-days");
const calendarTitle = document.querySelector("#calendar-title");
const calendarMonthFormat = new Intl.DateTimeFormat(undefined, { month: "long", year: "numeric" });
const calendarDayFormat = new Intl.DateTimeFormat(undefined, { dateStyle: "full" });
let calendarDay = new Date(date);

for (let index = 0; index < 7; index++) {
  const day = new Date(2026, 10, 1 + index, 12); // Sunday through Saturday.
  const label = element("span", new Intl.DateTimeFormat(undefined, { weekday: "narrow" }).format(day));
  label.setAttribute("role", "columnheader");
  label.setAttribute("aria-label", new Intl.DateTimeFormat(undefined, { weekday: "long" }).format(day));
  document.querySelector("#calendar-weekdays").append(label);
}

function renderCalendar(focusDay = false) {
  calendarTitle.textContent = calendarMonthFormat.format(calendarDay);
  calendarGrid.replaceChildren();
  const selected = dayKey(date);
  const today = dayKey(new Date());
  const active = dayKey(calendarDay);
  let week;
  calendarDaysForMonth(calendarDay).forEach((day, index) => {
    if (index % 7 === 0) {
      week = element("div", "", "tipoff-calendar-week");
      week.setAttribute("role", "row");
      calendarGrid.append(week);
    }
    const key = dayKey(day);
    const button = element("button", String(day.getDate()), "tipoff-calendar-day");
    button.type = "button";
    button.dataset.day = key;
    button.tabIndex = key === active ? 0 : -1;
    button.setAttribute("role", "gridcell");
    button.setAttribute("aria-label", calendarDayFormat.format(day));
    button.setAttribute("aria-selected", String(key === selected));
    if (key === today) button.setAttribute("aria-current", "date");
    if (day.getMonth() !== calendarDay.getMonth()) button.setAttribute("data-outside", "");
    week.append(button);
  });
  if (focusDay) calendarGrid.querySelector('[tabindex="0"]').focus({ preventScroll: true });
}

function positionCalendar() {
  if (!datePicker.matches(":popover-open")) return;
  const anchor = dateTitle.getBoundingClientRect();
  const panel = datePicker.getBoundingClientRect();
  const left = Math.max(8, Math.min(anchor.left + anchor.width / 2 - panel.width / 2, window.innerWidth - panel.width - 8));
  const below = anchor.bottom + 8;
  const top = below + panel.height <= window.innerHeight - 8 ? below : Math.max(8, anchor.top - panel.height - 8);
  datePicker.style.left = `${left}px`;
  datePicker.style.top = `${top}px`;
}

function chooseCalendarDay(key) {
  const selected = dateFromDayKey(key);
  if (!selected) return;
  date = selected;
  datePicker.hidePopover();
  dateTitle.focus({ preventScroll: true });
  loadDay();
}

datePicker.addEventListener("beforetoggle", event => {
  if (event.newState === "open") {
    calendarDay = dateFromDayKey(dayKey(date));
    renderCalendar();
  }
});
datePicker.addEventListener("toggle", event => {
  dateTitle.setAttribute("aria-expanded", String(event.newState === "open"));
  if (event.newState === "open") {
    positionCalendar();
    calendarGrid.querySelector('[tabindex="0"]').focus({ preventScroll: true });
  }
});
calendarGrid.addEventListener("click", event => {
  const button = event.target.closest("[data-day]");
  if (button) chooseCalendarDay(button.dataset.day);
});
calendarGrid.addEventListener("keydown", event => {
  const button = event.target.closest("[data-day]");
  if (!button) return;
  const day = dateFromDayKey(button.dataset.day);
  let offset;
  if (event.key === "ArrowLeft") offset = -1;
  else if (event.key === "ArrowRight") offset = 1;
  else if (event.key === "ArrowUp") offset = -7;
  else if (event.key === "ArrowDown") offset = 7;
  else if (event.key === "Home") offset = -day.getDay();
  else if (event.key === "End") offset = 6 - day.getDay();
  else if (event.key === "PageUp" || event.key === "PageDown") {
    calendarDay = shiftCalendarMonth(day, (event.key === "PageUp" ? -1 : 1) * (event.shiftKey ? 12 : 1));
  } else return;
  event.preventDefault();
  if (offset !== undefined) calendarDay = new Date(day.getFullYear(), day.getMonth(), day.getDate() + offset, 12);
  renderCalendar(true);
});
datePicker.addEventListener("keydown", event => {
  if (event.key === "Escape") {
    event.preventDefault();
    event.stopPropagation();
    datePicker.hidePopover();
    dateTitle.focus({ preventScroll: true });
  }
});
for (const [id, offset] of [["calendar-previous", -1], ["calendar-next", 1]]) {
  document.querySelector(`#${id}`).addEventListener("click", () => {
    calendarDay = shiftCalendarMonth(calendarDay, offset);
    renderCalendar();
    positionCalendar();
  });
}
document.querySelector("#calendar-today").addEventListener("click", () => chooseCalendarDay(dayKey(new Date())));
window.addEventListener("resize", positionCalendar);
window.addEventListener("scroll", positionCalendar, { passive: true });

document.querySelector("#zone").textContent = zone.replaceAll("_", " ");
for (const button of buttons.slice(1)) {
  const label = button.querySelector("span");
  const logo = mark(
    `https://a.espncdn.com/i/teamlogos/leagues/500/${button.dataset.league}.png`,
    "tipoff-league-logo"
  );
  logo.addEventListener("load", () => label.classList.add("tipoff-visually-hidden"), { once: true });
  button.prepend(logo);
}
buttons.forEach(button => button.addEventListener("click", () => select(button.dataset.league)));
document.querySelector("#previous").addEventListener("click", () => moveDay(-1));
document.querySelector("#next").addEventListener("click", () => moveDay(1));
document.querySelector("#today").addEventListener("click", () => {
  date = new Date();
  loadDay();
});
loadDay();
