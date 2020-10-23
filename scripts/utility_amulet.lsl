    /*

                          Utility Amulet

                    by John Walker (Fourmilab)

        This is a wearable bracelet which provides a variety of
        utility functions, including recovery from loss of control
        or animation due to turbulent region crossings and the
        ability to query a wide variety of information about the
        avatar, its environs, and the Second Life grid.  It also
        permits you to run animations and play or loop sound
        clips in the animation's inventory or set or clear
        animation overrides for various actions.

        When attached to an avatar, the bracelet listens for
        commands on local chat channel 77.  Commands are:

            Animation name
                Start or stop (if already running) the named animation,
                which can be either one of the internal animations
                (such as "sit" or "bow") or an animation stored in the
                object's inventory.  If no argument is given, list
                animations in the inventory.  Precede internal
                animation names with an asterisk.

            Attachments
                List attachments to the avatar.

            Avatar
                List information about the avatar to which we are attached.

            Boot
                Restart scripts.

            Calc expression
                Submit an expression to the Fourmilab Geometric Calculator.

            Clear
                Send blank space to chat.

            Fix controls
                Request permission to take control of navigation
                keys and, if granted, release them again after
                half a second.  This will, in many cases, recover
                loss of control after an un-seat or messy region
                crossing.  The most common symptom of this loss of
                control is being able to walk forward and back but
                not turn and/or an inability to fly.

            Fix animation
                Sometimes, after an un-seat, a passenger on a vehicle
                will be left stuck in an incorrect animation.  This
                command attempts to terminate a sitting animation and
                restore the default standing animation.  This doesn't
                seem to work as intended.  To do this, you must use
                llUnSit(), but for an avatar attachment this only works
                when the avatar is over land owner by the attachment's
                owner or to which they have group rights.  This means
                that in most cases of un-seats from vehicles crossing
                third party land, the llUnSit() will be silently
                ignored.  I know of no work-around for this at present.

            Go [ n/? ]
                If an argument of "?" is given, list avatars on the
                parcel other than the owner.  If no argument is
                given, teleport to the most recently-arrived avatar
                or, if none, list avatars.  Otherwise, teleport to
                the avatar designated by the number from the list of
                avatars or the item from the most recent Sensor scan,
                whichever is latest.

            Grid
                Show Second Life grid-wide statistics.

            Help
                Give user guide notecard to requester.

            Listen [ [ stop ] channel/* ]
                Listen for region messages on the specified channel, or
                stop listening on that or all channels.  With no
                argument, lists channels to which we're listening.

            Override [ Anim_state anim_name ]
                Show animation overrides or set animation override for state.
                    Override
                        List all animation states and overrides.
                    Override Animation State
                        List animation for Animation State.
                    Override Animation State = Animation name
                        Set override of Animation State to Animation name.

            Parcel
                Show information about the current parcel.

            Region
                Show information about the current region.

            Sensor [ range [ arc ] ]
                Perform a sensor scan for objects within range (default
                20 metres) and within arc degrees (default 180°) of the
                direction the avatar is facing.

            Sound [ play/loop/stop Clip name ]
                If no arguments, list sound clips in inventory.
                Otherwise play or loop the clip, or stop the present
                clip.  No clip name need be specified with stop.

            Status
                Show status on local chat.  The llGetAgentInfo(),
                llGetPermissions(), and llGetAnimation() values
                for the avatar are reported in local chat.

            Welcome forget / present / reset / status
                Pass command to Welcome module to forget other avatars,
                list avatars on property, reset the module and re-scan
                for avatars, or print internal status.

        All commands and arguments may be abbreviated to the first two
        letters.  Chat commands are accepted only from the avatar
        wearing the bracelet.

        Touching the bracelet requests controls and clicking
        it again releases them.  While controls are taken, the
        bracelet glows and control inputs are echoed in local
        chat.  This is a debugging feature to test taking and
        releasing controls; you should use "Fix controls" in most
        vehicle un-seat situations.

    */

    key owner;                  // Owner / wearer key
    integer commandChannel = 77;    // Command channel in chat
    integer commandH = 0;       // Handle for command channel
    key whoDat = NULL_KEY;      // Avatar who sent command
    integer restrictAccess = 2; // Access restriction: 0 none, 1 group, 2 owner
    integer echo = TRUE;        // Echo chat and script commands ?

    integer grabbed = FALSE;    // Toggle for take/release controls on touch
    integer cmdperm = FALSE;    // Processing permission grants from command ?

    //  Fixing controls and animations

    integer fixCtrl = FALSE;    // Fix controls ?
    integer fixAnim = FALSE;    // Fix animations ?

    //  Population queries and teleport to avatar

    list popuList = [ ];        // Eligible avatar targets on parcel
    key arrivalKey = NULL_KEY;  // Key of most recent arrival
    key TPkey;                  // Key of avatar to whom we should teleport

    //  Listening for region messages

    list listenChannel = [ ];   // Channels and handles to which we're listening

    //  Grid status queries

    string gridStatusPage = "http://secondlife.com/httprequest/homepage.php";
    key gridInfoH;              // Grid status request handle

    //  Animation overrides

    list ovargs;                // Override arguments
    string aoName;
    list stdanim = [
        "Crouching",
        "CrouchWalking",
        "Falling Down",
        "Flying",
        "FlyingSlow",
        "Hovering",
        "Hovering Down",
        "Hovering Up",
        "Jumping",
        "Landing",
        "PreJumping",
        "Running",
        "Sitting",
        "Sitting on Ground",
        "Standing",
        "Standing Up",
        "Striding",
        "Soft Landing",
        "Taking Off",
        "Turning Left",
        "Turning Right",
        "Walking"
    ];

    //  Greet module
    integer LM_GR_ARRIVAL = 32;     // Arrival of avatar
    integer LM_GR_DEPARTURE = 33;   // Departure of avatar

    //  Auxiliary script messages

//  integer LM_AU_RESET = 80;   // Reset script
    integer LM_AU_COMMAND = 81; // Process command

    //  Calculator messages

//  integer LM_CA_INIT = 210;       // Initialise script
//  integer LM_CA_RESET = 211;      // Reset script
    integer LM_CA_STAT = 212;       // Print status
    integer LM_CA_COMMAND = 213;    // Submit calculator command
//  integer LM_CA_RESULT = 214;     // Report calculator result

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

    //  checkAccess  --  Check if user has permission to send commands

    integer checkAccess(key id) {
        return (restrictAccess == 0) ||
               ((restrictAccess == 1) && llSameGroup(id)) ||
               (id == owner);
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    /*  inventoryName  --   Extract inventory item name from Set subcmd.
                            This is a horrific kludge which allows
                            names to be upper and lower case.  It finds the
                            subcommand in the lower case command then
                            extracts the text that follows, trimming leading
                            and trailing blanks, from the upper and lower
                            case original command.   */

    string inventoryName(string subcmd, string lmessage, string message) {
        //  Find subcommand in Set subcmd ...
        integer dindex = llSubStringIndex(lmessage, subcmd);
        //  Advance past space after subcmd
        dindex += llSubStringIndex(llGetSubString(lmessage, dindex, -1), " ") + 1;
        //  Note that STRING_TRIM elides any leading and trailing spaces
        return llStringTrim(llGetSubString(message, dindex, -1), STRING_TRIM);
    }

    //  showPop  --  Show population of parcel, update popuList

    showPop() {
        list population =  llGetAgentList(AGENT_LIST_PARCEL, []);
        integer n = llGetListLength(population);
        popuList = [ ];
        if (n < 2) {
            tawk("No visitors.");
        } else {
            integer i;
            string s = "Population: ";
            integer j = 0;

            for (i = 0; i < n; i++) {
                key k = llList2Key(population, i);
                if ((k != owner) && llOverMyLand(k)) {
                    j++;
                    s += "\n " + (string) j + ". " + llKey2Name(k);
                    popuList += k;
                }
            }
            tawk(s);
        }
    }

    //  beamMe  --  Teleport to current destination

    beamMe() {
        list dest = llGetObjectDetails(TPkey, [ OBJECT_NAME, OBJECT_POS, OBJECT_ROT ]);
        string TPdname = llList2String(dest, 0);
        vector TPdpos = llList2Vector(dest, 1);
        rotation TPdrot = llList2Rot(dest, 2);
        vector where = TPdpos + (<2, 0, 0> * TPdrot);
        tawk("Teleporting to " + TPdname + ".");
        llTeleportAgent(owner, "", where, TPdpos);
    }

    //  processCommand  --  Process a command

    integer processCommand(key id, string message, integer fromScript) {

        if (!checkAccess(id)) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        whoDat = id;            // Direct chat output to sender of command

        /*  If echo is enabled, echo command to sender unless
            prefixed with "@".  The command is prefixed with ">>"
            if entered from chat or "++" if from a script.  */

        integer echoCmd = TRUE;
        if (llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 0, 0) == "@") {
            echoCmd = FALSE;
            message = llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 1, -1);
        }
        if (echo && echoCmd) {
            string prefix = ">> ";
            if (fromScript) {
                prefix = "++ ";
            }
            tawk(prefix + message);                 // Echo command to sender
        }

        string lmessage = llToLower(llStringTrim(message, STRING_TRIM));
        list args = llParseString2List(lmessage, [" "], []);    // Command and arguments
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Boot                    Restart script

        if (abbrP(command, "bo")) {
            llResetOtherScript("Amulet Auxiliary");
            llResetOtherScript("Calculator");
            llResetOtherScript("Welcome");
            llResetScript();

        //  Calc                    Submit command to the calculator

        } else if (abbrP(command, "ca")) {
            llMessageLinked(LINK_THIS, LM_CA_COMMAND, message, id);

        //  Clear                   Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Fix animation/controls  Fix specific items

        } else if (abbrP(command, "fi")) {
            if (argn > 1) {

                //  Fix animation

                if (abbrP(sparam, "an")) {
                    string an = llGetAnimation(whoDat);
                    if (an != "Standing") {
                        fixAnim = TRUE;
                        llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
                    } else {
                        tawk("Already standing.");
                    }

                //  Fix controls

                } else if (abbrP(sparam, "co")) {
                    cmdperm = TRUE;
                    fixCtrl = TRUE;
                    llRequestPermissions(owner, PERMISSION_TAKE_CONTROLS);
                } else {
                    tawk("Unknown fix item.  Valid: animation/controls");
                }
            } else {
                tawk("Fix what?  animation/controls");
            }

        //  Go [ n/? ]              Teleport to avatar's location

        } else if (abbrP(command, "go")) {
            /*  If no argument and no recent arrival, or argument of "?",
                list non-owner avatars on parcel.  */
            if (((argn < 2) && (arrivalKey == NULL_KEY) ||
                (sparam == "?")) ) {
                showPop();
            } else {
                TPkey = NULL_KEY;
                /*  If no argument and recent arrival, go to arrival.
                    Otherwise, go to numbered avatar specified as argument.  */
                if ((argn < 2) && (arrivalKey != NULL_KEY)) {
                    TPkey = arrivalKey;
                    arrivalKey = NULL_KEY;
                } else {
                    integer n = llGetListLength(popuList);
                    if (n == 0) {
                        showPop();
                    } else {
                        integer l = (integer) sparam;
                        if ((l > 0) && (l <= n)) {
                            TPkey = llList2Key(popuList, l - 1);
                        }
                    }
                }
                if (TPkey != NULL_KEY) {
                    if ((llGetPermissions() & PERMISSION_TELEPORT) == 0) {
                        llRequestPermissions(owner, PERMISSION_TELEPORT);
                    } else {
                        beamMe();           // Already have permission to teleport
                    }
                } else {
                    tawk("No such visitor.");
                    return FALSE;
                }
            }

        //  Grid                    Print grid-wide statistics

        } else if (abbrP(command, "gr")) {
            gridInfoH = llHTTPRequest(gridStatusPage, [], "");

        //  Listen [ [ stop ] channel/* ]       Listen for region messages

        } else if (abbrP(command, "li")) {
            integer channel;
            integer listing = TRUE;
            integer stopping = FALSE;
            integer stopall = FALSE;
            integer stopped = FALSE;
            if (argn >= 2) {
                listing = FALSE;
                if (abbrP(sparam, "st")) {
                    stopping = TRUE;
                    sparam = llList2String(args, 2);
                    if (sparam == "*") {
                        stopall = TRUE;
                    }
                }
                channel = (integer) sparam;
            }
            integer i;
            integer p = llGetListLength(listenChannel);
            string lchans = "";

            for (i = 0; i < p; i += 2) {
                if (listing) {
                    lchans += (string) llList2Integer(listenChannel, i) + ", ";
                } else if (stopall) {
                    llListenRemove(llList2Integer(listenChannel, i + 1));
                } else {
                    if (llList2Integer(listenChannel, i) == channel) {
                        if (stopping) {
                            llListenRemove(llList2Integer(listenChannel, i + 1));
                            listenChannel = llDeleteSubList(listenChannel, i, i + 1);
                            stopped = TRUE;
                            i = p;
                        } else {
                            tawk("Already listening to channel.");
                            return FALSE;
                        }
                    }
                }
            }

            if (listing) {
                if (lchans == "") {
                    lchans = "None";
                } else {
                    lchans = llDeleteSubString(lchans, -2, -1);
                }
                tawk("Listening to channels: " + lchans);
            } else if (stopping) {
                if (stopall) {
                    listenChannel = [ ];
                } else {
                    if (!stopped) {
                        tawk("Not listening to channel " + (string) channel + ".");
                    }
                }
            } else {
                integer lh = llListen(channel, "", NULL_KEY, "");
                listenChannel = llListSort(listenChannel + [ channel, lh ], 2, TRUE);
            }

        //  Override                Show / set animation overrides

        } else if (abbrP(command, "ov")) {
            ovargs = args;
            aoName = inventoryName("ov", lmessage, message);
            llRequestPermissions(id, PERMISSION_OVERRIDE_ANIMATIONS);

        //  Sensor [ range [ arc ] ]    Perform sensor scan within range, arc  (default 20 m, 180 deg)

        } else if (abbrP(command, "se")) {
            float range = 20;           // Default range in metres
            float arc = 180;            // Default arc of scan (max angle from forward direction)
            if (argn > 1) {
                range = (float) sparam;
                if (argn > 2) {
                    arc = (float) llList2String(args, 2);
                }
            }
            llSensor("", NULL_KEY, ACTIVE | SCRIPTED | AGENT | PASSIVE, range, arc * DEG_TO_RAD);

        //  Sound [ play/loop/stop Clip name ]  Play or loop sound clip

        } else if (abbrP(command, "so")) {
            if (argn == 1) {
                //  No argument: list available sound clips
                integer n = llGetInventoryNumber(INVENTORY_SOUND);
                integer i;
                for (i = 0; i < n; i++) {
                    string s = llGetInventoryName(INVENTORY_SOUND, i);
                    if (s != "") {
                        tawk("  " + (string) (i + 1) + ". " + s);
                    }
                }
            } else {
                integer loopy = FALSE;
                if (abbrP(sparam, "pl") || (loopy = abbrP(sparam, "lo"))) {
                    //  Play/loop named sound clip
                    string aname = inventoryName(sparam, lmessage, message);
                    if (llGetInventoryType(aname) != INVENTORY_SOUND) {
                        tawk("No such sound in the inventory.");
                        return FALSE;
                    }
                    if (loopy) {
                        llLoopSound(aname, 1);
                    } else {
                        llPlaySound(aname, 1);
                    }
                } else if (abbrP(sparam, "st")) {
                    llStopSound();
                } else {
                    tawk("Invalid sound command.  Valid: play/loop/stop.");
                }
            }

        //  Status                  Print status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();
            tawk(llGetScriptName() + " status:\n" +
                 "    Agent Info: " + (string) llGetAgentInfo(whoDat) + "\n" +
                 "    Permissions: " + (string) llGetPermissions() + "\n" +
                 "    Animation: " + llGetAnimation(whoDat) + "\n" +
                 "    Animation list: " + llList2CSV(llGetAnimationList(whoDat)) + "\n" +
                 "    Script memory.  Free: " + (string) mFree +
                 "    Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)"
                );
            //  Sneaky way to request auxiliary script status
            llMessageLinked(LINK_THIS, LM_AU_COMMAND,
                llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);
            llMessageLinked(LINK_THIS, LM_CA_STAT, "", whoDat);
            llMessageLinked(LINK_THIS, LM_AU_COMMAND,
                llList2Json(JSON_ARRAY, [ "", "", "welcome", "status" ]), whoDat);

/*
        //  Test                    Run various tests

        } else if (abbrP(command, "te")) {
            if (argn > 1) {
                if (abbrP(sparam, "si")) {
                    llUnSit(whoDat);
                } else {
                    tawk("Unknown test item.  Valid: animation/controls");
                }
            }
*/

        //     Handled by the Amulet Auxiliary Script

        //  Anim                    Play/stop animation (internal or from inventory)
        //  Attachments             List attachments to avatar
        //  Avatar                  List avatar information
        //  Help                    Print command summary
        //  Parcel                  Parcel information
        //  Region                  Region information
        //  Welcome                 Greet module commands

        } else if (abbrP(command, "an") ||
                   abbrP(command, "at") ||
                   abbrP(command, "av") ||
                   abbrP(command, "he") ||
                   abbrP(command, "pa") ||
                   abbrP(command, "re") ||
                   abbrP(command, "we")
                  ) {
            llMessageLinked(LINK_THIS, LM_AU_COMMAND,
                llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);
        } else {
            tawk("Unknown command.  Use /" + (string) commandChannel +
                 " help for documentation.");
        }
        return TRUE;
    }

    default {

        on_rez(integer start_param) {
            owner = llGetOwner();
        }

        state_entry() {
            grabbed = FALSE;
            cmdperm = FALSE;
            fixAnim = fixCtrl = FALSE;
            whoDat = owner = llGetOwner();
            if (commandH == 0) {
                commandH = llListen(commandChannel, "", NULL_KEY, "");
                tawk("Listening on /" + (string) commandChannel);
            }
        }

        /*  Handle touch of bracelet.  This toggles taking and releasing
            of controls.  While controls are taken the bracelet will glow
            and control inputs will be echoed in local chat.  This is
            mostly for debugging.  */

        touch_start(integer num_detected) {
            float gloaming;
            if (grabbed) {
                llReleaseControls();
                grabbed = FALSE;
                gloaming = 0;
                llOwnerSay("Controls released.");
            } else {
                fixCtrl = TRUE;
                llRequestPermissions(owner, PERMISSION_TAKE_CONTROLS);
                gloaming = 0.1;
            }
            llSetLinkPrimitiveParamsFast(LINK_THIS,
                [ PRIM_GLOW, ALL_SIDES, gloaming ]);
        }

        //  Attachment to or detachment from an avatar

        attach(key attachedAgent) {
            if (attachedAgent != NULL_KEY) {
                whoDat = attachedAgent;
                if (commandH == 0) {
                    commandH = llListen(commandChannel, "", NULL_KEY, "");
                    tawk("Listening on /" + (string) commandChannel);
                }
            } else {
                llListenRemove(commandH);
                commandH = 0;
            }
        }

        /*  The run_time_permissions() event is received when granted
            permissions for various operations. We then make the
            request we're now permitted to submit.  */

        run_time_permissions(integer perm) {
            if (perm & PERMISSION_TAKE_CONTROLS) {
                if (fixCtrl) {
                    fixCtrl = FALSE;
                    llTakeControls(CONTROL_UP |
                                   CONTROL_DOWN |
                                   CONTROL_FWD |
                                   CONTROL_BACK |
                                   CONTROL_RIGHT |
                                   CONTROL_LEFT |
                                   CONTROL_ROT_RIGHT |
                                   CONTROL_ROT_LEFT |
                                   CONTROL_ML_LBUTTON, TRUE, TRUE);
                    /*  If we've taken the controls in response to a
                        "Fix controls" command, start a timer to
                        automatically release them after half a second.  */
                    if (cmdperm) {
                        llSetTimerEvent(0.5);
                    } else {
                        grabbed = TRUE;         // Set toggle for touch action
                    }
                    llOwnerSay("Controls taken.");
                }
            }

            if (perm & PERMISSION_TRIGGER_ANIMATION) {
                if (fixAnim) {
                    fixAnim = FALSE;
                    string an = llGetAnimation(whoDat);
                    string anin = "";
                    if (an == "Sitting") {
                        anin = "sit";
                    } else if (an == "Sitting on Ground") {
                        anin = "sit_ground_constrained";
                    }
                    if (anin != "") {
                        llStopAnimation(anin);
                        llStartAnimation("stand");

                        /*  Changing the animation to "stand" causes the avatar to
                            physically stand, but does not change its state from
                            a sitting state to "Standing".  To do that, we need to
                            perform an llUnSit().  But in an avatar attachment (as
                            opposed to a vehicle on which it's sitting), this only
                            works when the avatar is over land which the attachment's
                            owner owns or to which they have group rights.  This
                            means that in many cases of un-seats over third party
                            land, this  will have no effect, but there's no harm in
                            trying and it may help if you're deposited on your own
                            land or that where you have group rights.  */

                        llUnSit(whoDat);
                    } else {
                        tawk("Unknown animation state: " + an);
                    }
                }
            }

            //  Teleport to destination

            if (perm & PERMISSION_TELEPORT) {
                beamMe();
            }

            //  Query / set animation overrides

            if (perm & PERMISSION_OVERRIDE_ANIMATIONS) {
                integer ovargc = llGetListLength(ovargs);
                if (ovargc < 2) {
                    integer i;
                    integer n = llGetListLength(stdanim);

                    tawk("Animation overrides:");
                    for (i = 0; i < n; i++) {
                        string ao = llList2String(stdanim, i);
                        tawk("  " + ao + ": " + llGetAnimationOverride(ao));
                    }
                } else {
                    integer eq = llSubStringIndex(aoName, "=");
                    if (eq < 0) {
                        if (llListFindList(stdanim, [ aoName ]) < 0) {
                            tawk("Unknown animation state: " + aoName);
                        } else {
                            tawk("  " + aoName + ": " + llGetAnimationOverride(aoName));
                        }
                    } else {
                        string aState = llStringTrim(llGetSubString(aoName, 0, eq - 1),
                            STRING_TRIM);
                        if (llListFindList(stdanim, [ aState ]) < 0) {
                            tawk("Unknown animation state: " + aState);
                        } else {
                            string aAnim = llStringTrim(llDeleteSubString(aoName, 0, eq),
                                STRING_TRIM);
                            if (aAnim != "") {
                                if (llGetSubString(aAnim, 0, 0) == "*") {
                                    //  Internal animation: delete leading asterisk
                                    aAnim = llDeleteSubString(aAnim, 0, 0);
                                } else {
                                    //  If not internal animation, make sure it's in the inventory
                                    if (llGetInventoryType(aAnim) != INVENTORY_ANIMATION) {
                                        tawk("Cannot \"" + aState +
                                             "\": no animation \"" + aAnim + "\" in inventory.");
                                        return;
                                    }
                                }
                                llSetAnimationOverride(aState, aAnim);
                            } else {
                                llResetAnimationOverride(aState);
                            }
                        }
                    }
                }
            }
        }

        /*  Log control inputs received.  This is purely for testing
            whether we have successfully taken controls.  */

        control(key id, integer level, integer edge) {
            llOwnerSay("Control: level " + (string) level + " edge " + (string) edge);
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            if (channel == commandChannel) {
                processCommand(id, message, FALSE);
            } else {
                tawk("Listen: Channel " + (string) channel + "  Sender " +
                    name + " (" + (string) id + ")\n  \"" + message + "\"");
            }
        }

        //  Process messages from other scripts

        link_message(integer sender, integer num, string str, key id) {

            //  LM_GR_ARRIVAL (32): Arrival of avatar

            if (num == LM_GR_ARRIVAL) {
                tawk("Arrival: " + str);
                arrivalKey = id;

            //  LM_GR_DEPARTURE (33): Departure of avatar

            } else if (num == LM_GR_DEPARTURE) {
                tawk("Departure: " + str);
                arrivalKey = NULL_KEY;
            }
        }

        /*  The timer event is used to release controls a half second
            after we've obtained them via the "Fix controls" command.  */

        timer() {
            cmdperm = FALSE;
            llSetTimerEvent(0);
            llReleaseControls();
            tawk("Controls released.");
        }

        //  Response to sensor scan

        sensor(integer n) {
            integer i;
            vector p = llGetRootPosition();
            string U_deg = llUnescapeURL("%C2%B0");     // U+00B0 Degree Sign

            tawk("Sensor detected " + (string) n + " objects:");
            popuList = [ ];
            for (i = 0; i < n; i++) {
                string name = llDetectedName(i);
                vector dpos = llDetectedPos(i);
                float dist = llVecDist(p, dpos);
                vector sbear = dpos - p;
                vector sbearn = llVecNorm(sbear);
                vector tbearn = llRot2Fwd(llGetRootRotation());
                float rbear = llAcos(sbearn * tbearn);
                vector bdir = sbearn % tbearn;
                float bear = rbear;
                if (bdir.z < 0) {
                    bear = TWO_PI - bear;
                }

                popuList += [ llDetectedKey(i) ] ;
                tawk("  " + (string) (i + 1) + ".  " + name + "  " +
                    (string) llRound(dist) + " m  " +
                    (string) llRound(bear * RAD_TO_DEG) + U_deg);
            }
            if (n >= 16) {
                tawk("Warning: sensor detects a maximum of 16 objects.\n" +
                     "Additional objects not reported.");
            }
        }

        no_sensor() {
            tawk("Sensor detected nothing.");
            popuList = [ ];
        }

        //  Response to HTTP status queries

        http_response(key request_id, integer status, list metadata, string body) {
            if (request_id == gridInfoH) {

                if (status == 200) {
                    list gstats = llParseString2List(body, [ "\n" ], []);

                    integer sidx = llListFindList(gstats, [ "inworld" ]);
                    if (sidx >= 0) {
                        tawk("Users in-world: " + llList2String(gstats, sidx + 1));
                    }

                    sidx = llListFindList(gstats, [ "exchange_rate" ]);
                    if (sidx >= 0) {
                        tawk("Exchange rate: " + llList2String(gstats, sidx + 1) + " L$/USD");
                    }
                }
            }
        }
    }
