set volume 0.0
set tempo 64.0
set brightness 0.0
set density 0.0

proc setArp {} {
    puts stdout [format "inst 1"]
    flush stdout
}

proc setMel {} {
    puts stdout [format "inst 2"]
    flush stdout
}

proc setHarm {} {
    puts stdout [format "inst 3"]
    flush stdout
}

proc myExit {} {
    puts stdout [format "goodbye 0"]
    flush stdout
    exit
}

proc setVolume {value} {
    puts stdout [format "volume %f" $value]
    flush stdout
}

proc setTempo {value} {
    puts stdout [format "tempo %f" $value]
    flush stdout
}

proc setBrightness {value} {
    puts stdout [format "brightness %f" $value]
    flush stdout
}

proc setDensity {value} {
    puts stdout [format "density %f" $value]
    flush stdout
}


. config -bg black

frame .main -bg black

label .main.label -text \
"a breeze brings ...
by scott smallwood"

button .main.exit -text "Fade out and Quit" -bg grey66 -command myExit
button .main.inst1 -text "ARPS" -bg grey66 -command setArp
button .main.inst2 -text "MELS" -bg grey66 -command setMel
button .main.inst3 -text "HARM" -bg grey66 -command setHarm

scale .main.volume -from 0 -to 128 -length 300 \
-command { setVolume }  -variable volume \
-orient horizontal -label "Volume" \
-tickinterval 32 -showvalue true -bg grey66

scale .main.tempo -from 0 -to 128 -length 300 \
-command { setTempo }  -variable tempo \
-orient horizontal -label "Tempo" \
-tickinterval 32 -showvalue true -bg grey66

scale .main.brightness -from 0 -to 128 -length 300 \
-command { setBrightness }  -variable brightness \
-orient horizontal -label "Brightness" \
-tickinterval 32 -showvalue true -bg grey66

scale .main.density -from 0 -to 128 -length 300 \
-command { setDensity }  -variable density \
-orient horizontal -label "Density" \
-tickinterval 32 -showvalue true -bg grey66

pack .main.label -side top -padx 5
pack .main.inst1 -pady 10
pack .main.inst2 -pady 5
pack .main.inst3 -pady 5
pack .main.volume  -padx 10 -pady 5
pack .main.tempo  -padx 10 -pady 5
pack .main.brightness  -padx 10 -pady 5
pack .main.density  -padx 10 -pady 5
pack .main.exit -padx 5 -pady 10
pack .main -pady 10

