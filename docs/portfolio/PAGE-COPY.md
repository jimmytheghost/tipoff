# Tipoff

<!-- Ready-to-place page copy. Editorial/placement instructions live in HANDOFF.md. -->

Tipoff is a viewing guide for NBA, NFL, WNBA, NHL, and MLB games, available as a macOS menu bar app, a Windows system-tray app, and a browser guide. It brings together teams, local start times, and source-listed broadcasters without scores or live game updates.

[View the schedule](https://www.jimmyweber.com/tipoff) · [Source code and installation](https://github.com/jimmytheghost/tipoff)

## Why I made it

It has never been harder to watch sports. Alec Miller's Instagram sketch describes it perfectly.

<!-- KEEP THE EXISTING VIDEO HERE, with its poster, controls, and @alec.miller credit. -->

I built this because I was tired of checking the NBA schedule every day to figure out which channel or streaming service had a game. I’m a Nuggets and Broncos fan in Mountain Time, so there’s an Altitude-specific supplement for Nuggets games and highlighted Denver matchups in both guides. The Rockies and Avalanche get the same treatment in MLB and NHL.

So now watching sports isn't such a pain in the ass.

## The macOS menu bar app

The macOS version keeps the guide in the menu bar. Clicking the icon opens a compact panel with five sport tabs, daily navigation, and a list of matchups. Each game shows the teams, its scheduled start time in the computer’s time zone, and the TV or streaming broadcasters supplied by the source.

The panel is 360 points wide, with system typography, rounded game cards, and a mint accent. The menu bar icon changes with the selected sport. NBA games with qualifying national broadcasts appear before regional and subscription-only listings, with Nuggets games first within each group. Broncos, Avalanche, and Rockies games lead their respective sports. NFL also has a shortcut to the upcoming Sunday.

The app checks for new listings when opened, after wake, and every five minutes while running. Saved schedules remain available when a refresh fails, with the source and original freshness visible. Launch at login is optional. The app uses SwiftUI and requires macOS 15 or newer; Apple Silicon is the tested build target.

## The Windows system-tray app

The Windows version is a native C# / WPF app for 64-bit Windows 10 and 11. Left-clicking the basketball icon in the notification area opens or closes its 360-unit guide. The tray menu also provides app commands, including Refresh and Settings.

It includes the same five sports, local dates and start times, Colorado team highlights, NFL Sunday shortcut, and matched Altitude details. Teams, times, and broadcasters stay in a compact three-column layout. Source, freshness, fallback, and saved-listing labels remain visible when needed. The guide checks whether a refresh is due when opened, and it can also be refreshed manually.

Settings includes Light and Dark appearance and a Start Tipoff with Windows option. Appearance is saved between launches. The current-user installation script places the app in a stable location, creates a Start Menu shortcut, and launches it. After its first launch, Tipoff can start in the notification area at sign-in; an existing choice to disable startup is preserved.

The current Windows app is installed from source with Git and the .NET 9 SDK. There is no published Windows binary yet. The repository includes the installation instructions and PowerShell script.

## The browser guide

The website brings the schedule to desktop and phone browsers without installing either native app. It opens with Following and National Broadcasts for the selected day. Following currently contains the Nuggets, Broncos, Avalanche, and Rockies; it is a fixed set of teams rather than a visitor-configurable favorites list.

A followed game with national coverage appears once in the highlights and carries a National marker. All Games opens the complete schedule, with All, NBA, NFL, WNBA, NHL, and MLB filters. Those filters affect the full schedule while leaving the highlights in place.

Previous and next day controls, Today, and a calendar make it possible to look ahead. Dates and game times follow the browser’s time zone. On narrower screens, matchups shorten their names or use team logos when space is limited, while keeping the full names accessible.

Expanding a game reveals its supplied broadcast listings and any matching Altitude notes or show times. A footer disclosure contains each sport’s source and original update time, including saved-data and fallback labels. Saved schedules can appear while a background refresh runs. A failed source is reported separately so the other leagues remain usable.

[View the schedule](https://www.jimmyweber.com/tipoff)

## Colorado teams and Altitude

Nuggets, Broncos, Avalanche, and Rockies games receive priority within their sports. The Nuggets also have a personal supplement from Altitude’s published schedule. It is applied only when the date, opponent, home/away designation, and tipoff agree with the main schedule.

The supplement retains Altitude’s channel names, pregame and postgame times, and regional footnotes when provided. Saved Altitude listings keep their original freshness. It does not add an Altitude supplement for the Avalanche or determine which subscription or local channel a viewer can receive.

## Where the listings come from

NBA schedules use NBA.com with ESPN fallback. NFL and WNBA use ESPN. NHL and MLB use their league schedules with ESPN fallback. The guide names the source it is using and distinguishes fallback or saved listings.

Tipoff keeps schedule and broadcaster information, excluding scores, standings, live game clocks, and live-game telemetry from its models and saved caches. Broadcaster names come from the sources. A listing is not a promise of local reception, streaming access, League Pass eligibility, or complete coverage.

The native apps use separate SwiftUI and WPF interfaces. The browser guide uses HTML, CSS, and JavaScript, backed by PHP and a Linux build of the Swift schedule tool. Schedule caches are separated by sport, calendar date, and time zone. When a source fails or changes format, working saved listings are preserved with their original timestamps.

## Source and installation

Tipoff is a personal tool shared as-is under the MIT license. The current source supports all five sports on macOS and Windows. The published v0.2.0 download is an older macOS-only, NBA-only build; it does not represent the current five-sport apps. There is no automatic update service or promise of ongoing support.

[Source code and installation](https://github.com/jimmytheghost/tipoff) · [View the schedule](https://www.jimmyweber.com/tipoff)
