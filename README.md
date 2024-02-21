# RC2014-TMS9918A

I love the RC2014 modular form factor and I love the fact that it's an 8-bit computer built from new parts. However, my own nostalgia is for character graphics and bitmapped screens rather than terminals and serial i/o

## RC2014 + TMS

The addition of a video card takes the RC2014 to another level. The TMS9918A is a very capable chip (as used in many '80s computers including TI-99, Colecovision, Memotech MTX and MSX). It has a text mode, tile mode, multicolour bitmap mode and 32 16x16 sprites. Video RAM is 16k of dedicated RAM which is in addition to your machine's regular RAM and communication with the video ram is very fast. 

There is a small library of software for RC2014+TMS video card and I am actively adding to it. Porting programs and games from other systems with similar screen resolutions or the same video chip is easy and I found porting 3D Monster Maze lots of fun.

The built examples here in the cpm and 32k folders are mostly from J B Langston's repo, https://github.com/jblang/TMS9918A , just built for your convenience to run on a cp/m or classic 32k RC2014 (ie without the z180, z80ctl, or $bx port check)

J B Langston's repo also contains the files for making the video card. If you prefer, I'm supplying the module built and tested (with Mr Langston's permission) complete with video chip here: https://www.tindie.com/products/30454/

## A list of some of the binaries

TUTTUT.COM / TUTTUT.IHX - a port for RC2014 of the modern classic by David Stephenson. Part puzzle, part action.

3DMM.COM / 3DMM.IHX - a port of the classic game. "He is hunting you..."

MAZOGS.COM / MAZOGS.IHX - another port of a classic game. 

FERN.COM - Barnesley fern, plotted in bitmap mode

GTC.COM / GTC32.IHX - my own game, Grand Theft Cygnus. Steal as many of the Queen's swans as you can without her catching you

TMSLIFE.COM / TMSLIFE.IHX - a fast-moving version of Conway's Life. 

ASCII.COM / ASCII.IHX - simple demonstration of the two-colour 40-column text mode. The program just loads and displays a character set.

MANDEL.COM / MANDEL.IHX - mandelbrot using the TMS colour bitmap mode 

NYAN.COM / NYAN.IHX - Brilliant demo featuring AY sound. NYANGB.COM and NYANCHEESE.COM are variations, see J B Langston's repository for the source and more possible variations.

PLASMA.COM / PLASMA.IHX - another brilliant demo featuring a fast-moving plasma effect.

SIMON.COM / SIMON.IHX - go on, guess! A very playable game of Simon by yours truly, with graphic display and optionally (recommended) AY sound. Pick 4 keys from each quarter of the keyboard - I like Q O Z M. 

Sprite Designer - The TMS can display 32 sprites on-screen. They're single-colour but can be overlaid for multicolour sprites. This folder contains binaries for a work-in-progress sprite designer which will help anyone wanting to make multicolour sprites for a game, demo or just have fun drawing. 

## Viewing the .sc2 and .sc3 image files

For CPM, sc2view.com will take the .sc2 filename as an argument - eg sc2view arnie.sc2.  Ditto for sc3view.com

For 32k, the programs are self-contained with the viewer and image data in one file, so loading and running cyber.ihx will display the image.

The .sc2 and .sc3 images generally come from https://tomseditor.com/gallery/browse where there is a very large gallery of .sc2 and .sc3 images. I have created some myself.
