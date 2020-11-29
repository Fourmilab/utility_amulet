
                        Fourmilab Utility Amulet

                                  User Guide

Fourmilab Utility Amulet is a wearable accessory which provides a
variety of services useful to developers and explorers of the Second
Life virtual world.  The amulet has the form of a golden bracelet
which is worn by default on the left hand (you can change the attach
point and position on the body if you wish—it is not “rigged” to the
avatar skeleton).  It accepts commands submitted on local chat channel
77 by the wearer and responds in local chat to the wearer.  Commands
are as follows.

Chat Commands

Most chat commands and parameters, except those specifying names from
the inventory, may be abbreviated to as few as two characters and are
insensitive to upper and lower case.

    Animation [ anim_name ]
        Play the named animation (which must be specified exactly as in
        the inventory, including spaces and upper and lower case
        letters) or, if no argument is specified, list animations in
        the inventory.  If the animation is looped, it will be
        automatically cancelled in five seconds, or may be cancelled by
        entering another Animation command with the name of the running
        animation.  You can play an internal (Second Life built-in)
        animation such as “bow” or “backflip” by preceding its name
        with an asterisk.  Note that whether an animation plays through
        a single time or loops continuously is a property of the
        animation itself and cannot be selected when it is played; to
        stop a looping animation, enter a second Animation command with
        its name, or just wait for five seconds for the timer to stop
        it automatically.

    Attachments
        List attachments to the avatar including their attachment
        points.

    Avatar
        List information about the avatar wearing the amulet.  Sample
        output is:
            Avatar status:
              Name: Fourmilab Resident
              Scripts: Running 32  Total 32  Memory 2654208  Time 0.000068
              Cost: Server 0  Streaming 582.6162  Physics 1
              Complexity: 107774
              Hover height: -0.053
              Body shape: 0
              Position: <108.2531, 147.6201, 1201.063>  Bearing: 70° (E)
              Terrain: Ground 24.115 m  Water 20 m

    Boot
        Reset all scripts in the amulet.

    Calc [ expression / help ]
        Evaluate an expression with the Fourmilab Geometric Calculator.
        For complete documentation of the Calculator, enter the command
        “Calc help”.

    Colour query
        Query the colour database.  You can look up colours with the
        following specifications.  Wherever a value between 0 and 1 is
        required, you can give it as a percentage, for example 15%
        instead of 0.15.  Colour system names may be abbreviated to
        two letters except where more are required to avoid ambiguity
        (for example, between HSL and HSV).
            RGB <r, g, b>       Red, green, and blue values between
                                0 and 1.
            RGB (r, g, b)       Red, green, and blue values between 0
                                and 255.
            RGB #RRGGBB         Red, green, and blue values between 0
                                and 255, specified as two hexadecimal
                                digits (00 to FF) as in CSS and HTML.
            CMY <c, m, y>       Cyan, magenta, and yellow subtractive
                                colour values between 0 and 1.
            CMYK <c, m, y, k>   Cyan, magenta, yellow, and black values
                                between 0 and 1, as used in four colour
                                process printing.
            HSL <h, s, l>       Hue, saturation, and lightness values
                                between 0 and 1.  You can also specify
                                the hue as a colour wheel value in
                                degrees by appending a degree sign
                                (°) or “d”: hue values of 0.75, 270°,
                                and 270d are equivalent.
            HSV <h, s, v>       Hue, saturation, and value between 0
                                and 1.  Hue may be specified in degrees
                                as for HSL.
            TEMP degK           Colour of a black body emitting at a
                                temperature of degK degrees Kelvin (in
                                the range from 1000 to 40000 °K).
            YIQ <y, i, q>       Luminance (Y) and chroma (In-phase and
                                Quadrature) as used in NTSC television
                                broadcasting.  Y is a value between 0
                                and 1, while I is in the range ±0.5957
                                and Q is in the range ±0.5226.  The Y
                                value is a good approximation of the
                                appearance of a colour on a monochrome
                                display.
            YUV <y, u, v>       Luminance (Y) and chroma (U: blue
                                projection, V: red projection) as used
                                in PAL television broadcasting.  Y is
                                between 0 and 1, U ranges from ±0.436
                                and V from ±0.615.
            CSS Name            The named colour from the Cascading
                                Style Sheets (CSS).  If the name is
                                surrounded by quotes, for example
                                "Blue", then the match is exact and the
                                colour must be specified exactly as in
                                the standard, including upper and
                                lower case letters.  If unquoted, all
                                colours which contain the name,
                                ignoring letter case, will be returned.

        The colour (or colours, for a CSS query which matches more than
        one) will be reported in all of the colour systems, for example:
            RGB <0.82353, 0.41176, 0.11765>  #D2691E  RGB(210, 105, 30)  RGB(82%, 41%, 12%)
            HSL <0.06944, 0.75, 0.47059>  HSL(25°, 75%, 47%)
            HSV <0.06944, 0.85714, 0.82353>  HSV(25°, 86%, 82%)
            CMY <0.17647, 0.58824, 0.88235>  CMYK <0, 0.5, 0.85714, 0.17647>
            YIQ <0.50115, 0.34002, -0.00459>
            YUV <0.50115, -0.18901, 0.28272>
            TEMP 2177 °K
            CSS Chocolate <0.82353, 0.41176, 0.11765>
        The colour temperature (TEMP) is that in which the ratio of red
        to blue is closest to the specified colour: most colours cannot
        be closely approximated by black body emission.  A CSS colour
        name will be reported only if it is a close match to the
        specified colour.  For a grey scale value which approximates
        the appearance of a colour on a monochrome display, use the Y
        value from the YIQ or YUV representation for all components: in
        the above, <0.50115, 0.50115, 0.50115>.

    Clear
        Send white space to the local chat window to set off subsequent
        output from the existing transcript.

    Fix [ animations / controls ]
        When crossing between regions, either by walking, flying, or,
        especially, in a vehicle, you will occasionally lose some or
        all of the navigation keys and be unable to steer or move in
        certain directions.  The command “Fix controls” will release
        and re-acquire the controls in an attempt to correct the
        problem.  This doesn't always work, but in many cases,
        especially after being knocked off a vehicle in a failed region
        crossing or departing a vehicle after a long trip, it does the
        trick.  Similarly, after being kicked off a vehicle in a failed
        region crossing or by a “security orb”, you'll sometimes lose
        your avatar's animation and find yourself sitting when you're
        supposed to be standing.  “Fix animations” attempts to correct
        this.  These are work-arounds to correct problems due to flaws
        in Second Life.  They don't always work, but it's better to
        have some chance of recovering from such calamities than none
        at all.

    Go [ n / ? ]
        The Go command works with the Welcome module which is included
        with the Amulet.  When you're on your own property (land you
        own), the Welcome module monitors arrivals and departures of
        other avatars on the property and announces these events in
        local chat.  To teleport to the location of the most-recently
        arrived avatar, just enter “Go” with no argument.  Entering “Go
        ?” lists all avatars other than yourself currently on the
        properly, with numbers, and “Go n” teleports to the location of
        avatar number n from the list.  This command works only when
        you're on your own property.  If you have recently entered a
        Sensor command (see below), you can teleport to an object it
        detects by entering its number on the Go command; this works
        anywhere you are allowed to teleport.

    Grid
        Print information about the overall status of the Second Life
        Grid (virtual world), like the following:
            Users in-world: 34349
            Exchange rate: 241.4594 L$/USD
        The Linden Dollar (L$) to U.S. dollar (USD) exchange rate is an
        instantaneous market quote and may have changed (usually only
        slightly) if you subsequently buy or sell Linden Dollars.

    Help
        Give this notecard to the requester.  The Geometric Calculator
        has its own User Guide / Help file, which is requested by the
        command “Calc help”.

    Listen [ [ stop ] channel / * ]
        Listen for region messages [sent via llRegionSay()] on the
        specified channel and show them in local chat, identified by
        channel, sender's name and key (UUID), and content.  The
        channel may be any positive or negative integer.  Prefixing the
        channel number with “stop” terminates listening on that
        channel, and "Listen stop *” stops listening on all channels.
        The Listen command is useful when debugging objects that
        communicate with one another via region message channels, as it
        allows you to monitor traffic without modifying the objects
        that send and receive it.  Note that you cannot listen to
        messages sent to a different specific object with
        llRegionSayTo(), as they are only received by the designated
        receiver.

    Override [ state [ = [ anim_name ] ] ]
        Query animation overrides (all animations if no argument is
        given, or just the named state if specified), or set an
        animation override for a state with “= anim_name” or restore it
        to the default with “=” and no animation name.  The animation
        state and animation name from the inventory must be specified
        exactly, including spaces and upper and lower case letters. You
        can override with an internal (Second Life built-in) animation
        such as “walk” or “run” by preceding its name with an asterisk.
        Entering “Override” with no arguments will provide a list of
        all animation states.

    Parcel
        Show informtion about the current parcel, for example:
            Parcel information:
              Name: Fourmilab Island
              Description:
              Owner: Fourmilab Resident
              Area: 65536 m²
              Primitives: 10684 of 20000 maximum
              Flags: 1040188779 +ACCGRP +BAN +ENTRYALL +ENTRYGRP

    Region
        Show information about the current region, for example:
            Region information:
              Region: Fourmilab
              Grid location: <945, 1211, 0>
              Edge of world: North East South West
              Host name: sim10497.agni.lindenlab.com
              Frames per second: 44.28777
              Time dilation: 0.956117
              Region flags: 1048576 +DAMAGE +FIXSUN +TELEPORT
              Agents in region: 1
              Wind: <1.70936, 3.11594, 0>
            Environment:
              Agent limit: 44
              Dynamic pathfinding: enabled
              Estate ID: 51556
              Estate name: Fourmilab
              Frame number: 5717025
              Regions per CPU: 1
              Region idle: 0
              Region type: Estate / Full Region
              Region SKU: 024
              Start time: 2020-10-14 23:13:30
              Sim channel: Second Life Server
              Sim version: 2020-09-11T22:25:15.548903
              Host name: sim10497.agni.lindenlab.com
              Max prims: 20000
              Bonus factor: 1
              Whisper range: 10
              Chat range: 20
              Shout range: 100

    Sensor [ range [ arc ] ]
        Perform a sensor scan for objects within range (default 20
        metres) of the avatar and with a maximum angle in degrees of
        arc (default 180) with respect to the direction the avatar is
        facing (thus the default of 180 degrees performs a full-circle,
        all-azimuth scan).  A numbered list of objects found is shown,
        with the name, distance, and compass bearing to each, for
        example:
            Sensor detected 5 objects:
              1.  Door Assembly  4 m  296°
              2.  Gimbals  14 m  38°
              3.  Fourmilab Rocket  14 m  182°
              4.  Fourmilab Flocking Birds  17 m  43°
              5.  Fourmilab Target  20 m  141°
        You can teleport to any item in the list reported by the Sensor
        command by specifying its number in the “Go” command.  The
        Linden Scripting Language llSensor() facility reports a maximum
        of 16 objects.  If 16 objects are found, a warning is issued
        that additional objects within range may not have been
        reported.  In crowded areas, you may wish to restrict the range
        or angular sweep of a sensor scan to avoid clutter.  For
        example, “Sensor 5 45” will report only objects within 5 metres
        of the avatar within a 90° angle of the direction it is facing.

    Sound [ play / loop / stop sound_clip_name ]
        If entered with no arguments, lists sound clips in the
        inventory. The play and loop commands play or continuously loop
        the named sound_clip_name, which must be specified exactly as
        in the inventory, including spaces and upper and lower case
        letters. “Sound stop” stops the current sound clip or loop.
        Sound clips are always played with the maximum volume of 1.

    Status
        Show internal status of the Amulet's scripts, including script
        memory usage.

    Welcome forget / present / reset / status
        Control the Welcome module which, when on land owned by the
        wearer, tracks arrivals and departures of other avatars on the
        property.  The “forget" command forgets all avatars other than
        the owner currently on the property, and will consider avatars
        present as new arrivals.  The “present” command lists all
        avatars currently present, including the owner, with their
        times of arrival.  The “reset” command restarts the Welcome
        module and re-scans for the presence of avatars on the
        property.  The “status” command shows the internal status of
        the Welcome module and is of interest mainly to developers.

Inventory

The Animation, Override, and Sound commands access objects stored in
the Amulet's inventory.  You can list animations and sounds with the
corresponding commands.  You can add items to the inventory by editing
the Amulet while wearing it, displaying its Contents, and dragging
them from your Inventory to the Contents window.

License

This product (software, documents, and models) is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any medium or
format, and to remix, transform, and build upon the material for any
purpose, including commercially.  You must give credit, provide a link
to the license, and indicate if changes were made.  If you remix,
transform, or build upon this material, you must distribute your
contributions under the same license as the original.
