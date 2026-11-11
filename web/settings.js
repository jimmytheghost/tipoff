const preferencesKey = "tipoff.preferences.v1";
const accountUrl = "/tipoff/account";

function browserPreferences() {
  try {
    const value = JSON.parse(localStorage.getItem(preferencesKey));
    if (typeof value?.timeZone !== "string" || !Array.isArray(value.teams)) return null;
    return value;
  } catch {
    return null;
  }
}

function supportedZone(zone) {
  if (typeof zone !== "string" || !zone) return "";
  try {
    new Intl.DateTimeFormat(undefined, { timeZone: zone });
    return zone;
  } catch {
    return "";
  }
}

const deviceZoneLabel = "Use device time zone";
const utcZoneLabel = "Coordinated Universal Time (UTC)";
function zoneLocation(zone) {
  return zone.split("/").pop().replaceAll("_", " ");
}

function zoneTitle(zone) {
  if (zone === "UTC") return utcZoneLabel;
  return new Intl.DateTimeFormat("en", { timeZone: zone, timeZoneName: "longGeneric" })
    .formatToParts().find(part => part.type === "timeZoneName")?.value ?? zoneLocation(zone);
}

function timeZoneGroups(table) {
  const names = new Intl.DisplayNames(["en"], { type: "region" });
  return Object.entries(table).map(([name, entries]) => ({
    name,
    zones: entries.map(entry => {
      const zone = supportedZone(entry.zone) || entry.zones.find(supportedZone);
      if (!zone) return null;
      const label = entry.name || zoneTitle(zone);
      const keywords = [name, label, ...entry.cities, ...entry.zones,
        ...entry.countries.map(code => names.of(code)), ...entry.countries].join(" ");
      return { zone, label, cities: entry.cities, aliases: entry.zones, keywords };
    }).filter(Boolean),
  }));
}

function searchText(text) {
  return text.normalize("NFD").replace(/\p{Diacritic}/gu, "").toLowerCase();
}

function initializeZonePicker(picker) {
  const summary = picker.querySelector("summary");
  const selectedLabel = picker.querySelector("#tipoff-zone-current");
  const value = picker.querySelector("#tipoff-settings-zone");
  const search = picker.querySelector("#tipoff-zone-search");
  const results = picker.querySelector("#tipoff-zone-results");
  let groups;
  const request = fetch("/tipoff/time-zones.json?v=20261110-02", { signal: AbortSignal.timeout(5000) })
    .then(response => {
      if (!response.ok) throw new Error("Time zone list unavailable");
      return response.json();
    }).then(timeZoneGroups).catch(() => [{
      name: "Time zones",
      zones: (Intl.supportedValuesOf?.("timeZone") ?? [Intl.DateTimeFormat().resolvedOptions().timeZone])
        .map(zone => ({ zone, label: zoneTitle(zone), cities: [zoneLocation(zone)], aliases: [zone], keywords: zone })),
    }]);

  function select(zone) {
    value.value = zone;
    const matching = groups?.flatMap(group => group.zones).find(entry => entry.aliases.includes(zone));
    selectedLabel.textContent = zone ? matching?.label ?? zoneTitle(zone) : deviceZoneLabel;
  }

  function option({ zone, label, cities = [], aliases = [zone] }) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "tipoff-zone-option";
    button.setAttribute("aria-pressed", String(aliases.includes(value.value)));
    const title = document.createElement("span");
    title.textContent = label;
    button.append(title);
    if (cities.length) {
      const examples = document.createElement("small");
      examples.textContent = cities.join(", ");
      button.append(examples);
    }
    button.addEventListener("click", () => {
      select(zone);
      picker.open = false;
      summary.focus({ preventScroll: true });
    });
    return button;
  }

  function group(name, zones, showAll) {
    const section = document.createElement("section");
    const heading = document.createElement("h3");
    heading.textContent = name;
    section.append(heading, ...zones.slice(0, showAll ? zones.length : 7).map(option));
    if (!showAll && zones.length > 7) {
      const more = document.createElement("details");
      const label = document.createElement("summary");
      label.textContent = `Show ${zones.length - 7} more`;
      more.append(label, ...zones.slice(7).map(option));
      section.append(more);
    }
    return section;
  }

  function render() {
    const terms = searchText(search.value.trim()).split(/\s+/).filter(Boolean);
    const matches = text => terms.every(term => searchText(text).includes(term));
    const nodes = [];
    if (matches(deviceZoneLabel)) nodes.push(option({ zone: "", label: deviceZoneLabel }));
    for (const { name, zones } of groups ?? []) {
      const visible = zones.filter(zone => matches(zone.keywords));
      if (visible.length) nodes.push(group(name, visible, terms.length > 0));
    }
    if (groups && matches("UTC Coordinated Universal Time")) {
      nodes.push(group("Other", [{ zone: "UTC", label: utcZoneLabel }], true));
    }
    if (!nodes.length || !groups) {
      const status = document.createElement("p");
      status.setAttribute("role", "status");
      status.textContent = groups ? "No matching time zones." : "Loading time zones…";
      nodes.push(status);
    }
    results.replaceChildren(...nodes);
    results.scrollTop = 0;
  }

  search.addEventListener("input", render);
  search.addEventListener("keydown", event => {
    if (event.key !== "ArrowDown" && event.key !== "Enter") return;
    event.preventDefault();
    results.querySelector(".tipoff-zone-option")?.focus();
  });
  picker.addEventListener("toggle", () => {
    if (!picker.open) return;
    search.value = "";
    render();
    search.focus({ preventScroll: true });
  });
  request.then(data => {
    groups = data;
    select(value.value);
    if (picker.open) render();
  });
  picker.addEventListener("keydown", event => {
    if (event.key === "Escape" && picker.open) {
      event.preventDefault();
      event.stopPropagation();
      picker.open = false;
      summary.focus({ preventScroll: true });
    }
  });
  return { current: () => value.value, select, close: () => { picker.open = false; } };
}

async function accountRequest({ body, csrf, challenge = false, timeout = 12000 } = {}) {
  const response = await fetch(accountUrl + (challenge ? "?signin=1" : ""), {
    credentials: "same-origin",
    cache: "no-store",
    signal: AbortSignal.timeout(timeout),
    ...(body && {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-Tipoff-CSRF": csrf },
      body: JSON.stringify(body),
    }),
  });
  const result = await response.json().catch(() => null);
  if (!response.ok || !result) {
    throw new Error(result?.error || "Tipoff accounts are temporarily unavailable.");
  }
  return result;
}

let googleScript;
function loadGoogle() {
  if (window.google?.accounts?.id) return Promise.resolve();
  googleScript ??= new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = "https://accounts.google.com/gsi/client";
    script.async = true;
    const timer = setTimeout(failed, 10000);
    function failed() {
      clearTimeout(timer);
      script.remove();
      reject(new Error("Google sign-in could not load."));
    }
    script.addEventListener("load", () => {
      clearTimeout(timer);
      if (window.google?.accounts?.id) resolve();
      else failed();
    }, { once: true });
    script.addEventListener("error", failed, { once: true });
    document.head.append(script);
  }).catch(error => {
    googleScript = undefined;
    throw error;
  });
  return googleScript;
}

export function initializeSettings(applyPreferences, defaultTeamIds, { leagueMark, teamPickerMark }) {
  const form = document.querySelector("#tipoff-preferences");
  const picker = document.querySelector("#tipoff-zone-picker");
  if (!form || !picker) return;
  const defaultPreferences = { timeZone: "", teams: defaultTeamIds };
  const zone = initializeZonePicker(picker);
  const choices = document.querySelector("#tipoff-team-options");
  const account = document.querySelector("#tipoff-account-label");
  const signOut = document.querySelector("#tipoff-sign-out");
  const googleButton = document.querySelector("#tipoff-google-button");
  const retry = document.querySelector("#tipoff-account-retry");
  const message = document.querySelector("#tipoff-settings-message");
  const panel = form.closest("details");
  const tiles = new Map();
  const groupCounts = [];
  let guest = browserPreferences();
  let session;
  let catalog;
  let busy = false;
  let signInReady = false;

  const teamsRequest = fetch("/tipoff/teams.json?v=20261110-02", { signal: AbortSignal.timeout(10000) })
    .then(response => {
      if (!response.ok) throw new Error("Team settings could not load.");
      return response.json();
    });

  function valid(preferences) {
    return {
      timeZone: supportedZone(preferences.timeZone),
      teams: [...new Set(preferences.teams)].filter(id => tiles.has(id)),
    };
  }

  function updateTeamCounts() {
    for (const { count, buttons } of groupCounts) {
      count.textContent = buttons.filter(button => button.getAttribute("aria-pressed") === "true").length;
    }
  }

  function showPreferences(preferences) {
    const value = valid(preferences ?? defaultPreferences);
    zone.select(value.timeZone);
    const selected = new Set(value.teams);
    for (const [id, button] of tiles) button.setAttribute("aria-pressed", String(selected.has(id)));
    updateTeamCounts();
    applyPreferences(value, catalog);
  }

  function showAccount() {
    account.textContent = session?.signedIn ? "Signed in with Google" :
      session ? "Sign in to sync settings across devices." : "Google sign-in is unavailable.";
    signOut.hidden = !session?.signedIn;
    googleButton.hidden = !session || session.signedIn;
    retry.hidden = Boolean(session);
  }

  function setBusy(value) {
    busy = value;
    if (value) zone.close();
    signOut.disabled = value;
    for (const control of form.elements) control.disabled = value;
  }

  async function mutate(body) {
    setBusy(true);
    message.textContent = "";
    try {
      session = await accountRequest({ body, csrf: session?.csrf });
      signInReady = false;
      googleButton.replaceChildren();
      showAccount();
      showPreferences(session.signedIn ? session.preferences : guest);
      if (body.action === "save") message.textContent = "Settings saved to your account.";
      if (body.action === "logout") message.textContent = "Signed out.";
    } catch (error) {
      message.textContent = error.message || "Try again.";
    } finally {
      setBusy(false);
      if (body.action === "logout" && !session?.signedIn && panel.open) void showGoogleButton();
    }
  }

  async function showGoogleButton() {
    if (signInReady || busy || session?.signedIn) return;
    signInReady = true;
    retry.hidden = true;
    googleButton.textContent = "Loading Google sign-in…";
    try {
      session = await accountRequest({ challenge: true });
      showAccount();
      if (session.signedIn) {
        showPreferences(session.preferences);
        return;
      }
      await loadGoogle();
      const identity = window.google.accounts.id;
      identity.initialize({
        client_id: session.clientId,
        nonce: session.nonce,
        auto_select: false,
        callback: ({ credential }) => {
          if (busy) return;
          void mutate({ action: "login", credential, preferences: guest && valid(guest) });
        },
      });
      googleButton.replaceChildren();
      identity.renderButton(googleButton, { theme: "outline_dark", size: "large" });
    } catch {
      signInReady = false;
      googleButton.textContent = "";
      account.textContent = "Google sign-in is unavailable.";
      retry.hidden = false;
    }
  }

  const ready = Promise.all([teamsRequest, accountRequest({ timeout: 3000 }).catch(() => null)])
    .then(([teams, initialSession]) => {
      catalog = teams;
      session = initialSession;
      for (const [league, clubs] of Object.entries(catalog)) {
        const group = document.createElement("details");
        const label = document.createElement("summary");
        const count = document.createElement("span");
        count.className = "tipoff-team-count";
        label.append(leagueMark(league), league.toUpperCase(), count);
        const options = document.createElement("div");
        options.className = "tipoff-team-options";
        const buttons = [];
        const columns = new Map();
        for (const club of clubs) {
          const id = league + ":" + club.id;
          const tile = document.createElement("button");
          tile.type = "button";
          tile.className = "tipoff-team-tile";
          tile.title = club.name;
          tile.setAttribute("aria-label", club.name);
          tile.setAttribute("aria-pressed", "false");
          const mark = document.createElement("span");
          mark.className = "tipoff-team-tile-mark";
          const logo = teamPickerMark(league, club);
          if (logo) mark.append(logo);
          const name = document.createElement("span");
          name.textContent = club.nickname;
          tile.append(mark, name);
          tile.addEventListener("click", () => {
            tile.setAttribute("aria-pressed", String(tile.getAttribute("aria-pressed") !== "true"));
            updateTeamCounts();
          });
          tiles.set(id, tile);
          buttons.push(tile);
          const column = club.group ?? "Teams";
          if (!columns.has(column)) columns.set(column, []);
          columns.get(column).push(tile);
        }
        for (const [index, column] of [...columns].sort(([a], [b]) => a.localeCompare(b)).entries()) {
          const [name, teams] = column;
          const section = document.createElement("section");
          const heading = document.createElement("h3");
          heading.id = `tipoff-team-column-${league}-${index}`;
          heading.textContent = name;
          section.setAttribute("aria-labelledby", heading.id);
          section.append(heading, ...teams);
          options.append(section);
        }
        group.append(label, options);
        choices.append(group);
        groupCounts.push({ count, buttons });
      }
      showAccount();
      showPreferences(session?.signedIn ? session.preferences : guest);
      form.hidden = false;
      return true;
    }).catch(() => {
      message.textContent = "Settings could not load. Reload to try again.";
      return false;
    });

  panel.addEventListener("toggle", async () => {
    if (!panel.open) zone.close();
    else if (await ready && panel.open && session) void showGoogleButton();
  });
  retry.addEventListener("click", () => void showGoogleButton());
  signOut.addEventListener("click", () => void mutate({ action: "logout" }));
  form.addEventListener("submit", event => {
    event.preventDefault();
    if (busy) return;
    const teams = [...tiles].filter(([, tile]) => tile.getAttribute("aria-pressed") === "true").map(([id]) => id);
    const preferences = valid({ timeZone: zone.current(), teams });
    if (session?.signedIn) {
      void mutate({ action: "save", preferences });
      return;
    }
    guest = preferences;
    showPreferences(guest);
    try {
      localStorage.setItem(preferencesKey, JSON.stringify(guest));
      message.textContent = "Settings saved in this browser.";
    } catch {
      message.textContent = "Settings applied for this visit.";
    }
  });
  return ready;
}
