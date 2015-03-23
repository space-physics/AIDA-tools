#rgbi8_5_20mn

object Index: filter cycle rgbi8_5_20
observer ALIS team 2005/6

load stdpos
set t gopta.start 03:00:00
set t gopta.stop 06:30:00

set i gopta.items 8

set i gopta.interval0 5
set i gopta.interval1 5
set i gopta.interval2 5
set i gopta.interval3 5
set i gopta.interval4 5
set i gopta.interval5 5
set i gopta.interval6 5
set i gopta.interval7 5

set i gopta.expose0 2000
set i gopta.expose1 2000
set i gopta.expose2 2000
set i gopta.expose3 2000
set i gopta.expose4 2000
set i gopta.expose5 2000
set i gopta.expose6 2000
set i gopta.expose7 2000

set s gopta.filter0 5577
set s gopta.filter1 4278
set s gopta.filter2 5577
set s gopta.filter3 4278
set s gopta.filter4 6300
set s gopta.filter5 5577
set s gopta.filter6 4278
set s gopta.filter7 8446

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
new GT,1,2
binning 4,4
hw
play
play knapsu
