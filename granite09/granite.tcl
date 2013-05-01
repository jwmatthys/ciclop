set pitch 64.0
set press 10.0
set modwheel 0.0

proc myExit {} {
    global pitch
    puts stdout [format "NoteOff          0.0 1 %f 127" $pitch ]
    puts stdout [format "ExitProgram"]
    flush stdout
    exit
}

proc noteOn {pitchVal pressVal} {
    puts stdout [format "NoteOn           0.0 1 %f %f" $pitchVal $pressVal]
    flush stdout
}

proc printWhatz {tag value1 value2 } {
    puts stdout [format "%s %i %f" $tag $value1 $value2]
    flush stdout
}

proc changePress {value} {
    global press
    set press $value
    puts stdout [format "AfterTouch       0.0 1 %f" $press]
    flush stdout
}

proc changePitch {value} {
    global pitch
    set pitch $value     
    puts stdout [format "PitchBend        0.0 1 %f" $pitch]
    flush stdout
}

proc changeModWheel {value} {
    global modwheel
    set modwheel $value     
    puts stdout [format "ModWheel        0.0 1 %f" $modwheel]
    flush stdout
}

. config -bg black

frame .crackle -bg black

frame .drums -bg black

label .crackle.label -text \
"Wiggle Fingers
Arm Width = Amplitude
Arm Height = Pitch"

button .crackle.exit -text "Exit Program" -bg grey66 -command myExit

scale .crackle.pluckAmp -from 0 -to 128 -length 300 \
-variable press -command changePress \
-orient horizontal -label "Crackle Amplitude" \
-tickinterval 32 -showvalue true -bg grey66

scale .crackle.pitch -from 0 -to 128 -length 300 \
-command {changePitch }  -variable pitch \
-orient horizontal -label "Pitch (careful here!!)" \
-tickinterval 32 -showvalue true -bg grey66

label .instructions2 -text \
"Height of Hand on Arm = Density
Downbeat = Sync Pattern"

button .drums.on -text "Sync Pattern" -bg grey66 -command { noteOn $pitch $press}

scale .drums.modwheel -from 0 -to 128 -length 300 \
-command {changeModWheel }  -variable modwheel \
-orient horizontal -label "Density" \
-tickinterval 32 -showvalue true -bg grey66

pack .crackle.label -side top -padx 5
pack .crackle.exit -side left -padx 5
pack .crackle.pluckAmp 	-padx 10 -pady 5
pack .crackle.pitch 	-padx 10 -pady 5
pack .crackle -pady 10

pack .instructions2 -side top -pady 20
pack .drums.on -side left -padx 5
pack .drums.modwheel    -padx 10 -pady 5
pack .drums -pady 10

