#rgbi8_4_16mn

object Index: filter cycle rgbi8_4_16
observer ALIS team 2005/6

load stdpos
set t gopta.start 03:00:00
set t gopta.stop 06:30:00

set i gopta.items 8

set i gopta.interval0 4
set i gopta.interval1 4
set i gopta.interval2 4
set i gopta.interval3 4
set i gopta.interval4 4
set i gopta.interval5 4
set i gopta.interval6 4
set i gopta.interval7 4

set i gopta.expose0 1600
set i gopta.expose1 1600
set i gopta.expose2 1600
set i gopta.expose3 1600
set i gopta.expose4 1600
set i gopta.expose5 1600
set i gopta.expose6 1600
set i gopta.expose7 1600

filter 4278
set s gopta.filter0 hold
set s gopta.filter1 5577
set s gopta.filter2 4278
set s gopta.filter3 5577
set s gopta.filter4 6300
set s gopta.filter5 4278
set s gopta.filter6 5577
set s gopta.filter7 4278

set s gopta.position0 hold
set s gopta.position1 hold
set s gopta.position2 hold
set s gopta.position3 hold
set s gopta.position4 hold
set s gopta.position5 hold
set s gopta.position6 hold
set s gopta.position7 hold
position eiscat

play off
new GT,2,0
binning 4,4
hw
play
play knapsu
