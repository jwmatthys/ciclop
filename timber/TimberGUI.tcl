set sub1 0.0
set sub2 0.0
set sub3 0.0
set sub4 0.0
set marimba 0.0
set woodblock 0.0
set key 0

. config -bg black

frame .stuff -bg black

frame .stuff.marmframe -bg black
scale .stuff.marmframe.marimba -from 0 -to 128 -length 300 \
-variable marimba -command changeMarimba \
-orient horizontal -label "Marimba Happiness" \
-tickinterval 32 -showvalue true -bg grey66
button .stuff.marmframe.marmbutt -bitmap @bitmaps/Marimba.xbm \
    -background white -foreground black

frame .stuff.woodframe -bg black
scale .stuff.woodframe.woodblock -from 0 -to 128 -length 300 \
-command {changeWoodBlock }  -variable woodblock \
-orient horizontal -label "Woodpeckerishness" \
-tickinterval 32 -showvalue true -bg grey66
button .stuff.woodframe.woodbutt -bitmap @bitmaps/WoodBlocks.xbm \
    -background white -foreground black

frame .stuff.butts -bg black
# button .stuff.butts.sync -bitmap @bitmaps/Sync.xbm \
#    -width 100 -background white -foreground black -command Sync
button .stuff.butts.downbeat -bitmap @bitmaps/DownBeat.xbm \
    -background white -foreground black -command Downbeat

frame .stuff.butts.keybutts -bg grey66
button .stuff.butts.keybutts.key -bitmap @bitmaps/Key.xbm \
    -background black -foreground white
radiobutton .stuff.butts.keybutts.key0 -bg grey66 \
    -variable key -value 0 -text "Key1" -command KeyChange
radiobutton .stuff.butts.keybutts.key1 -bg grey66 \
    -variable key -value 1 -text "Key2" -command KeyChange
radiobutton .stuff.butts.keybutts.key2 -bg grey66 \
    -variable key -value 2 -text "Key3" -command KeyChange

button .stuff.butts.exit -bitmap @bitmaps/Exit.xbm \
    -background white -foreground black -command myExit

frame .stuff.sub -bg black

frame .stuff.sub.sub1frame -bg black

scale .stuff.sub.sub1frame.sub1 -from 0 -to 128 -length 200 \
-command {changesub1 }  -variable sub1 \
-orient horizontal -label "Bass Groove 1" \
-tickinterval 32 -showvalue true -bg grey66
button .stuff.sub.sub1frame.sub1butt -bitmap @bitmaps/Hand1.xbm \
    -command {changesub1 128} -background white -foreground black

frame .stuff.sub.sub2frame -bg black
scale .stuff.sub.sub2frame.sub2 -from 0 -to 128 -length 200 \
-command {changesub2 }  -variable sub2 \
-orient horizontal -label "Bass Groove 2" \
-tickinterval 32 -showvalue true -bg grey66
button .stuff.sub.sub2frame.sub2butt -bitmap @bitmaps/Hand2.xbm \
    -command {changesub2 128} -background white -foreground black

frame .stuff.sub.sub3frame -bg black
scale .stuff.sub.sub3frame.sub3 -from 0 -to 128 -length 200 \
-command {changesub3 }  -variable sub3 \
-orient horizontal -label "Bass Groove 3" \
-tickinterval 32 -showvalue true -bg grey66
button .stuff.sub.sub3frame.sub3butt -bitmap @bitmaps/Hand3.xbm \
    -command {changesub3 128} -background white -foreground black

frame .stuff.sub.sub4frame -bg black
scale .stuff.sub.sub4frame.sub4 -from 0 -to 128 -length 200 \
-command {changesub4 }  -variable sub4 \
-orient horizontal -label "Bass Groove 4" \
-tickinterval 32 -showvalue true -bg grey66
button .stuff.sub.sub4frame.sub4butt -bitmap @bitmaps/Hand4.xbm \
    -command {changesub4 128} -background white -foreground black

# pack .stuff.butts.sync -padx 5 -pady 10
pack .stuff.butts.downbeat -padx 5 -pady 10

pack .stuff.butts.keybutts.key -padx 5 -pady 5 -side left
pack .stuff.butts.keybutts.key0 -padx 5 -pady 10
pack .stuff.butts.keybutts.key1 -padx 5 -pady 10
pack .stuff.butts.keybutts.key2 -padx 5 -pady 10
pack .stuff.butts.keybutts -pady 10

pack .stuff.butts.exit -padx 5 -pady 30
pack .stuff.butts -pady 4 -side left

pack .stuff.marmframe.marimba -padx 2 -pady 1 -side left
pack .stuff.marmframe.marmbutt -padx 2 -pady 1 -side left
pack .stuff.marmframe
pack .stuff.woodframe.woodblock -padx 2 -pady 2 -side left
pack .stuff.woodframe.woodbutt -padx 2 -pady 1 -side left
pack .stuff.woodframe

pack .stuff.sub.sub1frame.sub1 -padx 2 -pady 1 -side left
pack .stuff.sub.sub1frame.sub1butt -padx 2 -pady 1 -side left
pack .stuff.sub.sub1frame
pack .stuff.sub.sub2frame.sub2 -padx 2 -pady 1 -side left
pack .stuff.sub.sub2frame.sub2butt -padx 2 -pady 1 -side left
pack .stuff.sub.sub2frame
pack .stuff.sub.sub3frame.sub3 -padx 2 -pady 1 -side left
pack .stuff.sub.sub3frame.sub3butt -padx 2 -pady 1 -side left
pack .stuff.sub.sub3frame
pack .stuff.sub.sub4frame.sub4 -padx 2 -pady 1 -side left
pack .stuff.sub.sub4frame.sub4butt -padx 2 -pady 1 -side left
pack .stuff.sub.sub4frame

button .stuff.bass -bitmap @bitmaps/Bass.xbm \
    -background white -foreground black \
    -command {changesub1 0; changesub2 0; changesub3 0; changesub4 0 }

pack .stuff.sub -side left
pack .stuff.bass -pady 30

pack .stuff -pady 10

proc myExit {} { puts stdout [format "ExitProgram"]
    flush stdout
    exit	}

proc Sync {} {  puts stdout [format "Sync 0.0 1 1"]
    flush stdout  }

proc Downbeat {} { puts stdout [format "DownBeat 0.0 1 1"]
    flush stdout  }

proc KeyChange {} { global key
    puts stdout [format "KeyChange 0.0 1 %i" $key]
    flush stdout  }

proc changeMarimba {value} {
    global marimba
    set marimba $value
    puts stdout [format "Marimba       0.0 1 %f" $marimba]
    flush stdout  }

proc changesub1 {value} {
    global sub1
    set sub1 $value
    puts stdout [format "Sub1       0.0 1 %f" $sub1]
    flush stdout  }

proc changesub2 {value} {
    global sub2
    set sub2 $value
    puts stdout [format "Sub2       0.0 1 %f" $sub2]
    flush stdout  }

proc changesub3 {value} {
    global sub3
    set sub3 $value
    puts stdout [format "Sub3       0.0 1 %f" $sub3]
    flush stdout  }

proc changesub4 {value} {
    global sub4
    set sub4 $value
    puts stdout [format "Sub4       0.0 1 %f" $sub4]
    flush stdout  }

proc changeWoodBlock {value} {
    global woodblock
    set woodblock $value     
    puts stdout [format "WoodBlock        0.0 1 %f" $woodblock]
    flush stdout }


