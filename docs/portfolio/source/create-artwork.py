"""Compose portfolio artwork from unmodified captures and existing Tipoff identity.
Run from any directory: python3 docs/portfolio/source/create-artwork.py (Pillow).
These are editorial compositions/diagrams, not additional application screenshots.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'docs/portfolio/assets'
FONT='/System/Library/Fonts/Supplemental/Arial.ttf'
BOLD='/System/Library/Fonts/Supplemental/Arial Bold.ttf'
def font(n,b=False): return ImageFont.truetype(BOLD if b else FONT,n)
def text(im,xy,t,n=24,color='#e6e9ec',b=False): ImageDraw.Draw(im).text(xy,t,font=font(n,b),fill=color)
def fit(im,path,box):
 p=Image.open(path).convert('RGBA'); p.thumbnail((box[2],box[3]),Image.Resampling.LANCZOS)
 im.paste(p,(box[0],box[1]),p)
# The existing icon appears unchanged; screenshots are proportionally scaled, never repainted.
for name,w,h in [('tipoff-overview',1800,1120),('tipoff-social-v1',1200,630)]:
 im=Image.new('RGB',(w,h),'#10151d'); scale=w/1800
 fit(im,ROOT/'img/Tipoff.png',(int(70*scale),int(50*scale),int(110*scale),int(110*scale)))
 text(im,(int(210*scale),int(48*scale)),'Tipoff',int(70*scale),b=True)
 text(im,(int(212*scale),int(135*scale)),'macOS  /  Windows  /  Web',int(30*scale),color='#96d9d0')
 y=int(260*scale)
 text(im,(int(80*scale),y-45*scale),'macOS',int(25*scale),b=True)
 text(im,(int(490*scale),y-45*scale),'Browser guide',int(25*scale),b=True)
 fit(im,OUT/'macos-nba-dark.png',(int(80*scale),y,int(340*scale),int((h-y-40))))
 fit(im,OUT/'web-national-desktop.jpg',(int(490*scale),y,int(1230*scale),int(h-y-40)))
 im.save(OUT/(name+'.png'),optimize=True)
# An abstract feature diagram deliberately avoids simulated Windows chrome or fabricated game data.
im=Image.new('RGB',(1600,900),'#14191f');d=ImageDraw.Draw(im)
text(im,(80,65),'Windows system-tray app',54,b=True)
text(im,(80,140),'Feature diagram · not a Windows screenshot',25,color='#a5a5a5')
steps=[('Tray icon','Left-click: open or close the guide','Right-click: app commands'),('Five-sport guide','Teams, local start times, broadcasters','Daily navigation and NFL Sunday shortcut'),('Settings','Light / Dark appearance','Start Tipoff with Windows')]
for i,(title,line1,line2) in enumerate(steps):
 x=80+i*500
 d.rounded_rectangle((x,270,x+450,660),radius=18,fill='#252525',outline='#626262',width=2)
 text(im,(x+28,310),str(i+1),26,color='#40f3df',b=True)
 text(im,(x+28,375),title,30,b=True)
 # Manually wrapped labels preserve readability without resembling a settings UI.
 import textwrap
 yy=450
 for line in [line1,line2]:
  for row in textwrap.wrap(line,width=30):
   text(im,(x+28,yy),row,22); yy+=34
  yy+=18
 if i<2: text(im,(x+462,425),'›',40,color='#40f3df')
text(im,(80,750),'Native C# / WPF · Windows 10/11 x64 · 360-unit flyout',27,color='#a5a5a5')
text(im,(80,800),'Install the current app from source using scripts/install-windows.ps1.',24,color='#a5a5a5')
im.save(OUT/'windows-feature-diagram.png',optimize=True)
