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

export function initializeSettings(applyPreferences, defaultTeamIds) {
  const form = document.querySelector("#tipoff-preferences");
  if (!form) return;
  const defaultPreferences = { timeZone: "", teams: defaultTeamIds };
  const zone = document.querySelector("#tipoff-settings-zone");
  const choices = document.querySelector("#tipoff-team-options");
  const account = document.querySelector("#tipoff-account-label");
  const signOut = document.querySelector("#tipoff-sign-out");
  const googleButton = document.querySelector("#tipoff-google-button");
  const retry = document.querySelector("#tipoff-account-retry");
  const message = document.querySelector("#tipoff-settings-message");
  const panel = form.closest("details");
  const checkboxes = new Map();
  const groupCounts = [];
  let guest = browserPreferences();
  let session;
  let catalog;
  let busy = false;
  let signInReady = false;

  const teamsRequest = fetch("/tipoff/teams.json?v=20261110-01", { signal: AbortSignal.timeout(10000) })
    .then(response => {
      if (!response.ok) throw new Error("Team settings could not load.");
      return response.json();
    });

  function valid(preferences) {
    return {
      timeZone: supportedZone(preferences.timeZone),
      teams: [...new Set(preferences.teams)].filter(id => checkboxes.has(id)),
    };
  }

  function updateTeamCounts() {
    for (const { count, inputs } of groupCounts) {
      count.textContent = inputs.filter(input => input.checked).length;
    }
  }

  function showPreferences(preferences) {
    const value = valid(preferences ?? defaultPreferences);
    if (value.timeZone && !Array.from(zone.options).some(option => option.value === value.timeZone)) {
      zone.add(new Option(value.timeZone.replaceAll("_", " "), value.timeZone));
    }
    zone.value = value.timeZone;
    const selected = new Set(value.teams);
    for (const [id, checkbox] of checkboxes) checkbox.checked = selected.has(id);
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
      identity.renderButton(googleButton, { theme: "outline", size: "large" });
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
      const zones = new Set(["UTC", ...(Intl.supportedValuesOf?.("timeZone") ?? []),
        Intl.DateTimeFormat().resolvedOptions().timeZone]);
      for (const value of [...zones].sort()) zone.add(new Option(value.replaceAll("_", " "), value));
      for (const [league, clubs] of Object.entries(catalog)) {
        const group = document.createElement("details");
        const label = document.createElement("summary");
        const count = document.createElement("span");
        label.append(league.toUpperCase(), count);
        const options = document.createElement("div");
        options.className = "tipoff-team-options";
        const inputs = [];
        for (const club of clubs) {
          const id = league + ":" + club.id;
          const row = document.createElement("label");
          const checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.value = id;
          checkbox.addEventListener("change", updateTeamCounts);
          checkboxes.set(id, checkbox);
          inputs.push(checkbox);
          row.append(checkbox, club.name);
          options.append(row);
        }
        group.append(label, options);
        choices.append(group);
        groupCounts.push({ count, inputs });
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
    if (panel.open && await ready && panel.open && session) void showGoogleButton();
  });
  retry.addEventListener("click", () => void showGoogleButton());
  signOut.addEventListener("click", () => void mutate({ action: "logout" }));
  form.addEventListener("submit", event => {
    event.preventDefault();
    if (busy) return;
    const teams = [...checkboxes].filter(([, checkbox]) => checkbox.checked).map(([id]) => id);
    const preferences = valid({ timeZone: zone.value, teams });
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
