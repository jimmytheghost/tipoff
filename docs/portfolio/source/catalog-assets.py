"""Rebuild the asset manifest, caption guide, and contact sheet (Pillow)."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import hashlib,json,textwrap
BASE=Path(__file__).resolve().parents[1]; OUT=BASE/'assets'
# filename, kind, caption, alt
rows=[
('tipoff-overview.png','editorial composition','Tipoff on macOS and in the browser. Composite of native view and live website captures.','Tipoff icon above a macOS schedule view and the desktop browser guide.'),
('macos-nba-dark.png','native view render','The macOS guide in Dark appearance, with Nuggets listings first. Production-view render using November 7, 2026 listings.','Dark macOS Tipoff guide showing five sport tabs and Nuggets at Pacers with Altitude 2, Altitude+, and NBA TV listings.'),
('macos-nba-light.png','native view render','The same macOS guide in Light appearance. Production-view render.','Light macOS Tipoff guide with five sport tabs, teams, local game times, and supplied broadcasters.'),
('macos-altitude-details.png','native view render','Matching Altitude listings include show times, regional notes when supplied, and their original check time. Production-view render.','Nuggets broadcast details from Altitude with game, pregame, postgame, and source freshness information.'),
('windows-feature-diagram.png','feature diagram','The Windows app’s tray, guide, and settings flow. Explanatory feature diagram, not a Windows screenshot.','Diagram describing the Windows tray icon, five-sport flyout, and Light, Dark, and startup settings; not a screenshot.'),
('web-following-desktop.jpg','live browser capture','Following highlights the Nuggets and Avalanche on November 7, 2026. No national broadcasts are listed for this selection.','Desktop browser guide with Nuggets and Avalanche highlights and All Games collapsed.'),
('web-national-desktop.jpg','live browser capture','The browser guide on November 8, 2026, with Broncos coverage in Following and the remaining national listings below.','Desktop Tipoff browser guide showing Broncos at Panthers and national NFL broadcasts with local start times.'),
('web-all-games-desktop.jpg','live browser capture','All Games expands the full schedule and five league filters below the highlights.','Expanded desktop All Games section with All, NBA, NFL, WNBA, NHL, and MLB filters and daily schedules.'),
('web-national-mobile.jpg','live browser capture','The November 8 browser guide at a 390-pixel phone viewport.','Phone layout of Following and national NFL broadcasts with logos, matchups, and scheduled start times.'),
('web-calendar-mobile.jpg','live browser capture','The browser calendar at a 390-pixel phone viewport, with November 8 selected.','Dark calendar popover over the phone schedule, showing November 2026 and the Today control.'),
('web-details-status-desktop.jpg','live browser capture','Expanded Nuggets broadcast details and the source/freshness disclosure. The live NBA and MLB responses used ESPN fallback in this capture.','Nuggets broadcaster details with pregame and postgame times, alongside the footer panel naming each sport’s source and update time.'),
('tipoff-social-v1.png','link preview composition','Proposed portfolio link-preview artwork. Not deployed.','Tipoff app icon with macOS and browser viewing-guide images.'),
('reference-tipoff-before.jpg','reference only','Existing Tipoff portfolio page before this proposed expansion.','Full-page reference capture of the previous Tipoff portfolio page.'),
('reference-pick-a-psych.jpg','reference only','Pick a Psych editorial reference; do not publish as Tipoff media.','Full-page reference capture of the Pick a Psych case study.'),
('reference-tzminifigs.jpg','reference only','tzMiniFigs editorial reference; do not publish as Tipoff media.','Full-page reference capture of the tzMiniFigs case study.')]
manifest=[]
for name,kind,caption,alt in rows:
 p=OUT/name; im=Image.open(p); im.verify(); im=Image.open(p)
 manifest.append(dict(file='assets/'+name,kind=kind,width=im.width,height=im.height,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),caption=caption,alt=alt,provenance=('Captured November 7, 2026 from https://www.jimmyweber.com/tipoff using the in-app browser; local times America/Denver.' if kind=='live browser capture' else 'See ASSETS.md for source and reproduction details.')))
(BASE/'asset-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
intro='''# Tipoff portfolio assets

Prepared November 7, 2026. Captions and alt text below are ready to use. Keep originals available for enlargement. Screenshots show historical schedules, not currently verified viewing access. Team/network artwork belongs to its respective owners; capture provenance does not grant independent rights to those logos. No scores or live telemetry were added.

## Page-ready files

'''
for r in manifest:
 if r['kind']=='reference only': continue
 intro+=f"### {Path(r['file']).name}\n\n- File: [{r['file']}]({r['file']}) — {r['width']} × {r['height']}, {r['kind']}.\n- Caption: {r['caption']}\n- Alt: {r['alt']}\n\n"
intro+='''## Provenance and reproduction

- macOS: `.build/debug/TipoffCheck 2026-11-07` fetched NBA.com + Altitude, seven games, during this task. `source/nba-2026-11-07.json` is the unmodified score-free schedule snapshot produced by that check. It includes public schedule/broadcaster fields and their original timestamps; no visitor data. Renders were made with the existing local TipoffCheck production-view renderer (binary built November 6). No source code was changed or recompiled. This is not an interactive menu-bar capture.
- To regenerate a native render, build TipoffCheck if necessary, copy the supplied snapshot to an ignored temporary path such as `.build/portfolio-render.png.json`, then run `.build/debug/TipoffCheck --render .build/portfolio-render.png`. Use `--light` or `--altitude-details` for the other variants. Copy only the PNG to its selected asset path. Regenerating on another day may change relative-date/freshness labels; do not edit the snapshot to make it appear newly fetched.
- Browser: captured from the live `/tipoff` route in the in-app browser, November 7, selecting November 7 or 8 through date controls. Desktop main captures used 1440-pixel width; expanded details/status used the 1280-pixel default viewport. Phone captures used a 390 × 844 viewport with no invented device frame. Team and broadcaster images loaded from the actual guide. The phone full-page image is 390 × 1097. Temporary viewport overrides were reset. Initial malformed phone-scale captures were replaced and visually checked.
- Reference-only full-page captures: the three URLs in HANDOFF.md, inspected the same day. They are for the next agent’s editorial comparison, not assets to publish within Tipoff.
- Overview/social: run `python3 docs/portfolio/source/create-artwork.py` from the repository. Pillow required; Arial/Arial Bold are loaded from macOS system fonts. Existing `img/Tipoff.png` plus unmodified macOS and browser captures are proportionally placed on a flat background. These are compositions, not an actual multi-platform desktop. The small text in social artwork is illustrative; project name and identifying artwork carry the preview.
- Windows: the same script draws an abstract feature-flow diagram based on `Windows/Tipoff.App/App.xaml.cs`, `MainWindow.xaml`, `MainViewModel.cs`, and `SettingsWindow.xaml`, plus README. It contains no simulated game listings, OS chrome, or claimed WPF render. Keep the prominent diagram label. No Windows desktop was accessible for this task.
- `python3 docs/portfolio/source/catalog-assets.py` rebuilds the manifest, this guide, and the contact sheet. Manifest hashes identify the exact delivered image bytes. The existing untracked `img/Tipoff-banner.png` was not used or changed.

## Optional Windows screenshot replacement brief

On a real Windows 10/11 x64 machine, follow README and `scripts/install-windows.ps1` to use the stable current-user installation. Capture: (1) Dark guide with the tray icon visible and a populated day, (2) the same guide in Light, (3) expanded Nuggets Altitude details if supplied for a matching day, and (4) Settings showing appearance and startup controls. Use the actual 360-unit flyout at a normal display scale; record display scaling, app revision, local date/time zone, selected schedule date, source, saved/fallback state, and whether startup was actually changed. Do not enable startup solely to stage a screenshot. Exclude unrelated tray icons, notifications, usernames, private paths, and other windows from the shared image. Preserve source/freshness labels and original timestamps. Save PNG captures with names `windows-guide-dark.png`, `windows-guide-light.png`, `windows-altitude-details.png`, and `windows-settings.png`. If a source fails, show the genuine saved/fallback state or choose another populated date; do not fabricate a healthy state. Add dimensions/provenance/captions to the manifest and replace the diagram only after inspecting the real captures.

## Reference-only files

- [Existing Tipoff page](assets/reference-tipoff-before.jpg)
- [Pick a Psych](assets/reference-pick-a-psych.jpg)
- [tzMiniFigs](assets/reference-tzminifigs.jpg)

These, `source/`, the manifest, the contact sheet, and handoff Markdown stay out of the final page’s media directory.
'''
(BASE/'ASSETS.md').write_text(intro)
# Review sheet: thumbnails plus type, with original screenshots linked through ASSETS.md.
selected=[r for r in manifest if r['kind']!='reference only']
W=1800;cellW=600;cellH=520;H=((len(selected)+2)//3)*cellH
sheet=Image.new('RGB',(W,H),'#ebedf0');d=ImageDraw.Draw(sheet)
f=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',20)
for i,r in enumerate(selected):
 x=(i%3)*cellW;y=(i//3)*cellH
 p=Image.open(BASE/r['file']).convert('RGB');p.thumbnail((560,390),Image.Resampling.LANCZOS)
 sheet.paste(p,(x+20+(560-p.width)//2,y+16))
 d.text((x+20,y+420),Path(r['file']).name,font=f,fill='#17202c')
 d.text((x+20,y+450),r['kind'],font=f,fill='#475268')
sheet.save(BASE/'CONTACT-SHEET.jpg',quality=88)
print(f'Verified and cataloged {len(manifest)} images; {len(selected)} page-ready assets.')
