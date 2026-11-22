from PIL import Image, ImageDraw
from pathlib import Path
import math

out = Path("assets")
out.mkdir(exist_ok=True)
S = 1024

def make_icon(adaptive=False):
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0) if adaptive else (24, 23, 22, 255))
    px = im.load()
    if not adaptive:
        for y in range(S):
            t = y / (S - 1)
            c = (int(33 - 12*t), int(31 - 18*t), int(29 - 18*t), 255)
            for x in range(S):
                px[x, y] = c
    d = ImageDraw.Draw(im)
    # Fine orbital rings and central compass mark
    gold = (244, 137, 29, 255)
    pale = (255, 246, 234, 255)
    if not adaptive:
        d.rounded_rectangle((36, 36, 988, 988), radius=220, outline=(244,137,29,190), width=10)
    d.ellipse((218, 218, 806, 806), outline=(244,137,29,230), width=17)
    d.ellipse((276, 276, 748, 748), outline=(57,143,196,140), width=5)
    # Compass needle: elegant four-point directional form
    cx, cy = 512, 512
    points = [(cx+18,cy-258),(cx+106,cy+35),(cx+20,cy+8),(cx-88,cy+258),(cx-18,cy-35),(cx-4,cy-8)]
    d.polygon(points, fill=pale)
    d.line((cx-170,cy+174,cx+170,cy-174), fill=gold, width=13)
    d.ellipse((cx-26,cy-26,cx+26,cy+26), fill=gold)
    d.ellipse((cx+220,cy-260,cx+270,cy-210), fill=gold)
    return im

make_icon(False).save(out / "discoverly_launcher.png")
make_icon(True).save(out / "discoverly_foreground.png")
print("Generated DISCOVERLY launcher assets")
