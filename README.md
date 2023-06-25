# RC2014-TMS9918A

I love the RC2014 modular form factor and I love the fact that it's an 8-bit computer built from new parts. However, my own nostalgia is for character graphics and bitmapped screens rather than terminals and serial i/o

## RC2014 + TMS

The addition of a video card takes the RC2014 to another level. The TMS9918A is a very capable chip (as used in many '80s computers including TI-99, Colecovision, Memotech MTX and MSX). It has a text mode, tile mode, multicolour bitmap mode and 32 16x16 sprites. Video RAM is 16k of dedicated RAM which is in addition to your machine's regular RAM and communication with the video ram is very fast. 

There is a small library of software for RC2014+TMS video card and I am actively adding to it. Porting programs and games from other systems with similar screen resolutions or the same video chip is easy and I found porting 3D Monster Maze lots of fun.

The built examples here in the cpm and 32k folders are mostly from J B Langston's repo, https://github.com/jblang/TMS9918A , just built for your convenience to run on a cp/m or classic 32k RC2014 (ie without the z180, z80ctl, or $bx port check)

J B Langston's repo also contains the files for making the video card. If you prefer, I'm supplying the module built and tested (with Mr Langston's permission) complete with video chip here: https://www.tindie.com/products/30454/

## Viewing the .sc2 files

For CPM, sc2view.com will take the .sc2 filename as an argument - eg sc2view arnie.sc2
For 32k, the programs are self-contained with the viewer and image data in one file, so loading and running cyber.ihx will display the image.

