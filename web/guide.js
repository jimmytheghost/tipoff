const buttons = [...document.querySelectorAll("[data-league]")];
const zone = Intl.DateTimeFormat().resolvedOptions().timeZone;
const dateTitle = document.querySelector("#date");
const leagues = document.querySelector("#leagues");
const followedLeagues = document.querySelector("#followed-leagues");
const followedStatus = document.querySelector("#followed-status");
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

function leagueHeader(tag, id, label) {
  const title = element(tag, "", "tipoff-league-header");
  title.id = id;
  const name = element("span", label, "tipoff-header-name");
  name.id = `${id}-name`;
  const gameCount = element("span", "", "tipoff-league-count");
  const status = element("span", "", "tipoff-league-freshness");
  status.setAttribute("role", "status");
  title.append(name, gameCount, status);
  return { title, name, gameCount, status };
}

function summaryGroup(parent, id, label) {
  const group = element("section", "", "tipoff-league");
  const { title, name, gameCount, status } = leagueHeader("h3", id, label);
  group.setAttribute("aria-labelledby", name.id);
  const games = element("ul", "", "tipoff-games");
  const warning = element("p", "", "tipoff-league-status");
  warning.hidden = true;
  group.append(title, warning, games);
  group.hidden = true;
  parent.append(group);
  return { group, title, games, gameCount, status, warning };
}

function resetSummary({ group, title, games }) {
  title.querySelector(".tipoff-national-marker")?.remove();
  group.hidden = true;
  games.replaceChildren();
}

const sections = new Map(buttons.slice(1).map(button => {
  const id = button.dataset.league;
  const section = element("section", "", "tipoff-league");
  const { title, name, gameCount, status } = leagueHeader("h2", `league-${id}`, button.textContent);
  section.setAttribute("aria-labelledby", name.id);
  const results = element("div");
  section.append(title, results);
  leagues.append(section);
  const national = summaryGroup(nationalLeagues, `national-${id}`, button.textContent);
  const followedTeam = followedTeams.get(id);
  const followed = followedTeam && summaryGroup(followedLeagues, `followed-${id}`, followedTeam.name);
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
  ["espn", "https://a.espncdn.com/i/espn/espn_logos/espn_red.png"],
  ["espn+", "https://upload.wikimedia.org/wikipedia/commons/8/80/ESPN_Plus.svg"],
  ["hulu", "https://upload.wikimedia.org/wikipedia/commons/f/f9/Hulu_logo_%282018%29.svg"],
  ["disney+", "https://upload.wikimedia.org/wikipedia/commons/7/77/Disney_Plus_logo.svg"],
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
  const label = element("span", shortTeamName(name), "tipoff-team-name");
  label.title = name;
  line.append(label);
  return line;
}

function broadcastList(broadcasts) {
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
    const logo = networkLogos.get(key);
    if (key === "league pass" || key === "nba league pass") {
      item.classList.add("tipoff-pass");
      item.append(element("span", "LP", "tipoff-station-tag"));
      item.firstChild.setAttribute("aria-hidden", "true");
    } else if (categories.some(category => /^(home|away|local|regional)\b/.test(category))) {
      item.append(element("span", "Regional", "tipoff-station-tag"));
    }
    const label = element("span", name);
    if (logo) {
      const image = mark(logo, "tipoff-network-logo");
      if (["espn+", "cbs", "fox", "peacock", "tnt", "hbo max", "trutv", "altitude", "alt", "altitude 2", "alt2"].includes(key)) image.classList.add("tipoff-network-logo-light");
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

function gameRow(game, league, broadcasts, highlight, collapseBroadcasts = false) {
  const row = element("li", "", "tipoff-game");
  if (highlight) row.classList.add(highlight);
  const start = game.start ? timeFormat.format(new Date(game.start)) : "Time TBD";
  const matchup = element("span", "", "tipoff-matchup");
  const home = element("span", "", "tipoff-matchup-home");
  home.append(element("span", " @ ", "tipoff-matchup-separator"), team(game.home, game.homeCode, league));
  matchup.append(team(game.away, game.awayCode, league), home);
  let heading = row;
  let content = row;
  if (collapseBroadcasts) {
    content = element("details", "", "tipoff-game-details");
    heading = element("summary", "", "tipoff-game-toggle");
    content.append(heading);
    row.append(content);
  }
  const nationalBroadcasts = broadcasts.filter(broadcast => isNationalBroadcast(broadcast, league));
  if (nationalBroadcasts.length) {
    heading.classList.add("tipoff-game-inline");
    const logos = broadcastList(nationalBroadcasts);
    logos.classList.add("tipoff-inline-broadcasts");
    heading.append(logos);
  }
  heading.append(matchup, element("span", start, "tipoff-start"));
  if (game.notice) heading.append(element("span", game.notice, "tipoff-game-notice"));
  const nationalNames = new Set(nationalBroadcasts.map(broadcast => broadcast.name.trim().toLowerCase()));
  const otherBroadcasts = broadcasts.filter(broadcast =>
    !nationalNames.has(broadcast.name.trim().toLowerCase()) && !broadcast.category.toLowerCase().includes("radio"));
  if (!nationalBroadcasts.length || otherBroadcasts.length) content.append(broadcastList(otherBroadcasts));
  if (game.altitude && broadcasts === game.broadcasts) {
    const details = element("details", "", "tipoff-altitude");
    const altitude = game.altitude;
    details.append(element("summary", "Altitude details"));
    details.append(element("p", altitude.networks.join(", ")));
    if (altitude.pregame) details.append(element("p", `Pregame ${timeFormat.format(new Date(altitude.pregame))}`));
    if (altitude.postgame) details.append(element("p", `Postgame ${timeFormat.format(new Date(altitude.postgame))}`));
    for (const note of altitude.notes) details.append(element("p", note));
    details.append(element("p", `${altitude.saved ? "Saved Altitude data" : "Altitude updated"} ${stampFormat.format(new Date(altitude.fetchedAt))}`, "tipoff-meta"));
    content.append(details);
  }
  return row;
}

async function loadLeague(id, day, signal) {
  const { section, title, gameCount, status, results, national, followed } = sections.get(id);
  section.replaceChildren(title, results);
  gameCount.textContent = "";
  const summaries = followed ? [national, followed] : [national];
  const followedTeam = followedTeams.get(id);
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
    gameCount.textContent = `${count} ${count === 1 ? "game" : "games"}`;
    const updated = stampFormat.format(new Date(snapshot.fetchedAt));
    status.replaceChildren(
      element("span", snapshot.source, "tipoff-league-source"),
      element("span", `${saved ? "Refresh failed, saved" : "Updated"} ${updated}`)
    );
    for (const summary of summaries) {
      summary.status.replaceChildren(...[...status.children].map(node => node.cloneNode(true)));
      summary.warning.hidden = !(id === "nba" && snapshot.altitudeWarning);
      summary.warning.textContent = id === "nba" ? snapshot.altitudeWarning ?? "" : "";
    }
    if (count) {
      const list = element("ul", "", "tipoff-games");
      for (const game of snapshot.games) {
        const nationalBroadcasts = game.broadcasts.filter(broadcast => isNationalBroadcast(broadcast, id));
        const isFollowed = followedTeam && [game.awayCode, game.homeCode]
          .some(code => followedTeam.codes.includes(code.toUpperCase()));
        let highlight;
        if (isFollowed) highlight = "tipoff-game-followed";
        else if (nationalBroadcasts.length) highlight = "tipoff-game-national";
        list.append(gameRow(game, id, game.broadcasts, highlight, !highlight));
        if (isFollowed) {
          followed.games.append(gameRow(game, id, game.broadcasts));
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
    if (snapshot.altitudeWarning) results.append(element("p", snapshot.altitudeWarning, "tipoff-meta"));
    if (count === 0) {
      results.append(element("p", "No games scheduled.", "tipoff-meta"));
      const details = element("details", "", "tipoff-inactive-league");
      const toggle = element("summary");
      toggle.append(title);
      details.append(toggle, results);
      section.replaceChildren(details);
    }
    return true;
  } catch {
    if (signal.aborted) return;
    results.replaceChildren();
    summaries.forEach(resetSummary);
    gameCount.textContent = "";
    status.textContent = "Schedule unavailable.";
    return false;
  }
}

async function loadDay() {
  request?.abort();
  request = new AbortController();
  const key = dayKey(date);
  dateTitle.textContent = dayKey(new Date()) === key ? `Today · ${dateFormat.format(date)}` : dateFormat.format(date);
  const { signal } = request;
  following.hidden = true;
  highlightsTitle.textContent = "National Broadcasts";
  nationalTitle.hidden = true;
  followedStatus.textContent = "";
  nationalStatus.textContent = "Checking national broadcasts…";
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
  const missingFollowed = loaded.some((result, index) => !result && followedTeams.has(ids[index]));
  const hasFollowedGames = Boolean(followedLeagues.querySelector("section:not([hidden])"));
  following.hidden = !hasFollowedGames && !missingFollowed;
  highlightsTitle.textContent = hasFollowedGames ? "Following" : "National Broadcasts";
  nationalTitle.hidden = !hasFollowedGames;
  followedStatus.textContent = missingFollowed ? "Some followed team schedules are unavailable." : "";
  if (loaded.some(result => !result)) {
    nationalStatus.textContent = "Some league schedules are unavailable.";
  } else {
    nationalStatus.textContent = nationalLeagues.querySelector("section:not([hidden])")
      ? "" : "No other national broadcasts listed.";
  }
}

function moveDay(offset) {
  date = new Date(date.getFullYear(), date.getMonth(), date.getDate() + offset, 12);
  loadDay();
}

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
