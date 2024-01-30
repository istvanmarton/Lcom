reset

set encoding utf8

wlabel_pos_x = -0.07
wlabel_pos_y = 1.04

colorbox_size_x = 1
colorbox_size_y = 0.05
colorbox_origin_x = 0
colorbox_origin_y = 1.12
cblabel_offset_x = 0
cblabel_offset_y = 7.5

xtics_offset_x = 0
xtics_offset_y = 1.75
ytics_offset_x = 0
ytics_offset_y = 0

p0 = "Bold Bold, 42"
p1 = "Bold Bold, 60"
set term eps size 28, 28
set out 'oneBit_all.eps'

set size ratio 1/1
set border linewidth 10

set key spacing 1.4
set xtics out
set ytics out
set x2tics
set xtics scale 3
set ytics scale 3
set x2tics scale 3
set y2tics scale 3
set cbtics scale 0
set multiplot layout 2, 2 margins 0.06, 0.95, 0.02, 0.90 spacing 0.05, 0.05

set ytics ("10" 9, "20" 19, "30" 29, "40" 39, "50" 49, "60" 59)
set xtics ("" 9, "" 19, "" 29, "" 39, "" 49, "" 59)
set x2tics ("10" 9, "20" 19, "30" 29, "40" 39, "50" 49, "60" 59)
set y2tics ("" 9, "" 19, "" 29, "" 39, "" 49, "" 59)
set y2tics out
set link y2
set link x2
unset label
unset key
set pm3d map
set cblabel ""
set ytics nomirror
set xlabel ""
set tics font p0
set ytics offset ytics_offset_x, ytics_offset_y tc "black"
set x2tics offset xtics_offset_x, xtics_offset_y
set label "(a)" at graph wlabel_pos_x, wlabel_pos_y tc rgb "black" font p1 front
fileName = 'W63.txt'
set colorbox horizontal user origin graph colorbox_origin_x,colorbox_origin_y size graph colorbox_size_x,colorbox_size_y
set cbtics font p0 offset cblabel_offset_x,cblabel_offset_y
set cbtics ("-1" -0.625, "0" 0.125, "1" 0.875, "2" 1.625) # -1+3/8, -1+3/8+1*3/4, -1+3/8+2*3/4, -1+3/8+3*3/4
set palette maxcolors 4
set palette defined(-1 "#4B0082", 0 "turquoise" ,1 "goldenrod", 2 "#aeff00")
set yrange [62.5:-0.5]
plot fileName matrix with image


set link y2
set link x2
unset label
unset key
set ytics nomirror
set pm3d map
set ytics nomirror
set xlabel ""
set tics font p0
set ytics offset ytics_offset_x, ytics_offset_y tc "black"
set label "(b)" at graph wlabel_pos_x, wlabel_pos_y tc rgb "black" font p1 front
fileName = 'E1bit_63.txt'
set colorbox horizontal user origin graph colorbox_origin_x,colorbox_origin_y size graph colorbox_size_x,colorbox_size_y
set cbtics font p0 offset cblabel_offset_x,cblabel_offset_y
set cbtics ("-1, c=0" -0.625, "-1, c=1" 0.125, "1, c=0" 0.875, "1, c=1" 1.625) # -1+3/8, -1+3/8+1*3/4, -1+3/8+2*3/4, -1+3/8+3*3/4
set palette defined(-1 "#000000" ,0 "#7c7c7c" ,1 "#FFFFFF" ,2 "#FFFFFF")
plot fileName matrix with image

unset colorbox
set ytics ("10" 9, "20" 19, "30" 29, "40" 39, "50" 49, "60" 59, "70" 69, "80" 79, "90" 89)
set xtics ("" 9, "" 19, "" 29, "" 39, "" 49, "" 59, "" 69, "" 79, "" 89)
set x2tics ("10" 9, "20" 19, "30" 29, "40" 39, "50" 49, "60" 59, "70" 69, "80" 79, "90" 89)
set y2tics ("" 9, "" 19, "" 29, "" 39, "" 49, "" 59, "" 69, "" 79, "" 89)
set link y2
set link x2
unset label
unset key
set ytics nomirror
set pm3d map
set cblabel ""
set ytics nomirror
set xlabel ""
set tics font p0
set ytics offset ytics_offset_x, ytics_offset_y tc "black"
set label "(c)" at graph wlabel_pos_x, wlabel_pos_y tc rgb "black" font p1 front
fileName = 'W90.txt'
set cbtics font p0 offset cblabel_offset_x,cblabel_offset_y
set cbtics ("-1" -0.625, "0" 0.125, "1" 0.875, "2" 1.625) # -1+3/8, -1+3/8+1*3/4, -1+3/8+2*3/4, -1+3/8+3*3/4
set palette maxcolors 4
set palette defined(-1 "#4B0082", 0 "turquoise" ,1 "goldenrod", 2 "#aeff00")
set yrange [89.5:-0.5]
plot fileName matrix with image

set arrow from 67, screen 0.95 to 67, screen 0.97 nohead lw 10

set link y2
set link x2
unset label
unset key
set ytics nomirror
set pm3d map
set ytics nomirror
set xlabel ""
set tics font p0
set ytics offset ytics_offset_x, ytics_offset_y tc "black"
set label "(d)" at graph wlabel_pos_x, wlabel_pos_y tc rgb "black" font p1 front
fileName = 'E1bit_90.txt'
set cbtics font p0 offset cblabel_offset_x,cblabel_offset_y
set cbtics ("-1, c=0" -0.75, "-1, c=1" -0.25, "1, c=0" 0.25, "1, c=1" 0.75) # -1+3/8, -1+3/8+1*3/4, -1+3/8+2*3/4, -1+3/8+3*3/4
set palette defined(-1 "#000000" ,0 "#7c7c7c" ,1 "#FFFFFF" ,2 "#FFFFFF")
plot fileName matrix with image

unset multiplot

set out
