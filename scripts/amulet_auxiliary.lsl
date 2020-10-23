     /*

                          Utility Amulet
                    Auxiliary Command Processor

                    by John Walker (Fourmilab)

        This script contains self-contained commands deported from the
        main script to avoid script memory crises.  None of the
        commands implemented in this script require large amounts of
        dynamically allocated memory (for example, as used in the
        results of sensor scan or query for avatars on a parcel), so as
        long as you follow that rule, feel free to pile lots of code in
        here, right up to the limit, without fretting over exhaustion.
        This frees up space in the main script, which does require
        dynamic memory allocation for some of its commands.

    */

    key owner;                  // Owner/wearer of attachment
    key whoDat = NULL_KEY;      // Avatar who sent command

    string helpFileName = "Fourmilab Utility Amulet User Guide";    // Help file

    //  Animation control

    string reqAnim = "";        // Requested animation
    string runAnim = "";        // Running animation
    integer relAnim = FALSE;    // Waiting to release animation ?

    //  Link messages

    //  Auxiliary script messages

//  integer LM_AU_RESET = 80;   // Reset script
    integer LM_AU_COMMAND = 81; // Process command

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

    //  ef  --  Edit floats in string to parsimonious representation

    string efv(vector v) {
        return ef((string) v);
    }

    string eff(float f) {
        return ef((string) f);
    }

/*
    string efr(rotation r) {
        return efv(llRot2Euler(r) * RAD_TO_DEG);
    }
*/

    //  Static constants to avoid costly allocation
    string efkdig = "0123456789";
    string efkdifdec = "0123456789.";

    string ef(string s) {
        integer p = llStringLength(s) - 1;

        while (p >= 0) {
            //  Ignore non-digits after numbers
            while ((p >= 0) &&
                   (llSubStringIndex(efkdig, llGetSubString(s, p, p)) < 0)) {
                p--;
            }
            //  Verify we have a sequence of digits and one decimal point
            integer o = p - 1;
            integer digits = 1;
            integer decimals = 0;
            string c;
            while ((o >= 0) &&
                   (llSubStringIndex(efkdifdec, (c = llGetSubString(s, o, o))) >= 0)) {
                o--;
                if (c == ".") {
                    decimals++;
                } else {
                    digits++;
                }
            }
            if ((digits > 1) && (decimals == 1)) {
                //  Elide trailing zeroes
                integer b = p;
                while ((b >= 0) && (llGetSubString(s, b, b) == "0")) {
                    b--;
                }
                //  If we've deleted all the way to the decimal point, remove it
                if ((b >= 0) && (llGetSubString(s, b, b) == ".")) {
                    b--;
                }
                //  Remove everything we've trimmed from the number
                if (b < p) {
                    s = llDeleteSubString(s, b + 1, p);
                    p = b;
                }
                //  Done with this number.  Skip to next non digit or decimal
                while ((p >= 0) &&
                       (llSubStringIndex(efkdifdec, llGetSubString(s, p, p)) >= 0)) {
                    p--;
                }
            } else {
                //  This is not a floating point number
                p = o;
            }
        }
        return s;
    }

    //  attPoints  --  Names of attachment points

    string attPoint(integer n) {
        list atpName = [
            "Chest",                //  1
            "Skull",                //  2
            "Left Shoulder",        //  3
            "Right Shoulder",       //  4
            "Left Hand",            //  5
            "Right Hand",           //  6
            "Left Foot",            //  7
            "Right Foot",           //  8
            "Spine",                //  9
            "Pelvis",               // 10
            "Mouth",                // 11
            "Chin",                 // 12
            "Left Ear",             // 13
            "Right Ear",            // 14
            "Left Eye",             // 15
            "Right Eye",            // 16
            "Nose",                 // 17
            "R Upper Arm",          // 18
            "R Lower Arm",          // 19
            "L Upper Arm",          // 20
            "L Lower Arm",          // 21
            "Right Hip",            // 22
            "R Upper Leg",          // 23
            "R Lower Leg",          // 24
            "Left Hip",             // 25
            "L Upper Leg",          // 26
            "L Lower Leg",          // 27
            "Stomach",              // 28
            "Left Pec",             // 29
            "Right Pec",            // 30
            "HUD Center 2",         // 31
            "HUD Top Right",        // 32
            "HUD Top",              // 33
            "HUD Top Left",         // 34
            "HUD Center",           // 35
            "HUD Bottom Left",      // 36
            "HUD Bottom",           // 37
            "HUD Bottom Right",     // 38
            "Neck",                 // 39
            "Avatar Center",        // 40
            "Left Ring Finger",     // 41
            "Right Ring Finger",    // 42
            "Tail Base",            // 43
            "Tail Tip",             // 44
            "Left Wing",            // 45
            "Right Wing",           // 46
            "Jaw",                  // 47
            "Alt Left Ear",         // 48
            "Alt Right Ear",        // 49
            "Alt Left Eye",         // 50
            "Alt Right Eye",        // 51
            "Tongue",               // 52
            "Groin",                // 53
            "Left Hind Foot",       // 54
            "Right Hind Foot"       // 55
        ];

        return llList2String(atpName, n - 1);
    }

    //  parcelFlags  --  Interpret llGetParcelFlags() bit values

    string parcelFlags(integer pflags) {
        string pft = "";
        if ((pflags & PARCEL_FLAG_ALLOW_FLY) == 0) {
            pft += " -FLY";
        }
        if ((pflags & PARCEL_FLAG_ALLOW_SCRIPTS) == 0) {
            pft += " -SCRIPTS";
        }
        if (pflags & PARCEL_FLAG_USE_ACCESS_GROUP) {
            pft += " +ACCGRP";
        }
        if (pflags & PARCEL_FLAG_USE_ACCESS_LIST) {
            pft += " +ACCLIST";
        }
        if (pflags & PARCEL_FLAG_USE_BAN_LIST) {
            pft += " +BAN";
        }
        if (pflags & PARCEL_FLAG_USE_LAND_PASS_LIST) {
            pft += " +PASS";
        }
        if (pflags & PARCEL_FLAG_ALLOW_ALL_OBJECT_ENTRY) {
            pft += " +ENTRYALL";
        }
        if (pflags & PARCEL_FLAG_ALLOW_GROUP_OBJECT_ENTRY) {
            pft += " +ENTRYGRP";
        }
        return pft;
    }

    //  regionFlags  --  Interpret llGetRegionFlags() bit values

    string regionFlags(integer rflags) {
        string rft =  "";
        if ((rflags & REGION_FLAG_ALLOW_DAMAGE) == 0) {
            rft +=  " +DAMAGE";
        }
        if ((rflags & REGION_FLAG_FIXED_SUN) == 0) {
            rft +=  " +FIXSUN";
        }
        if (rflags & REGION_FLAG_BLOCK_TERRAFORM) {
            rft +=  " -TERRAFORM";
        }
        if (rflags & REGION_FLAG_SANDBOX) {
            rft +=  " +SANDBOX";
        }
        if (rflags & REGION_FLAG_DISABLE_COLLISIONS) {
            rft +=  " -COLLISIONS";
        }
        if (rflags & REGION_FLAG_DISABLE_PHYSICS) {
            rft +=  " -PHYSICS";
        }
        if (rflags & REGION_FLAG_BLOCK_FLY) {
            rft +=  " -FLY";
        }
        if (rflags & REGION_FLAG_ALLOW_DIRECT_TELEPORT) {
            rft +=  " +TELEPORT";
        }
        if (rflags & REGION_FLAG_RESTRICT_PUSHOBJECT) {
            rft +=  " -PUSH";
        }
        return rft;
    }

    //  cardinalPoint  --  Output compass cardinal point for bearing angle in degrees

    string cardinalPoint(float bear) {
        list cards = [ "N", "NE", "E", "SE", "S", "SW", "W", "NW" ];

        integer ibear = llRound((bear / 360) * 8);
        if (ibear > 7) {
            ibear = 0;
        }
        return llList2String(cards, ibear);
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

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  processAuxCommand  --  Process a command

    integer processAuxCommand(key id, list args) {

        whoDat = id;            // Direct chat output to sender of command

        string message = llList2String(args, 0);
        string lmessage = llList2String(args, 1);
        args = llDeleteSubList(args, 0, 1);
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
//      string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Anim                    Play/stop animation (internal or from inventory)

        if (abbrP(command, "an")) {
            if (argn == 1) {
                //  No argument: list available animations
                integer n = llGetInventoryNumber(INVENTORY_ANIMATION);
                integer i;
                for (i = 0; i < n; i++) {
                    string s = llGetInventoryName(INVENTORY_ANIMATION, i);
                    if (s != "") {
                        tawk("  " + (string) (i + 1) + ". " + s);
                    }
                }
            } else {
                //  Start named animation
                string aname = inventoryName("an", lmessage, message);
                if (llGetSubString(aname, 0, 0) == "*") {
                    //  Internal animation: delete leading asterisk
                    aname = llDeleteSubString(aname, 0, 0);
                } else {
                    //  If not internal animation, make sure it's in the inventory
                    if (llGetInventoryType(aname) != INVENTORY_ANIMATION) {
                        tawk("No such animation in the inventory.");
                        return FALSE;
                    }
                }
                if (runAnim == aname) {
                    //  Manually cancel running animation
                    llStopAnimation(runAnim);
                    runAnim = "";
                    //  Revoke timer cancellation of animation
                    if (relAnim) {
                        relAnim = FALSE;
                        llSetTimerEvent(0);
                    }
                } else {
                    //  Manually cancel named animation
                    reqAnim = aname;
                    llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
                }
            }

        //  Attachments             List attachments to avatar

        } else if (abbrP(command, "at")) {
            key okey = llGetOwnerKey(llGetKey());
            list ats = llGetAttachedList(okey);
            integer n = llGetListLength(ats);
            integer i;

            tawk("Attachments:");
            for (i = 0;  i < n; i++) {
                list od = llGetObjectDetails(llList2Key(ats, i),
                    [ OBJECT_NAME, OBJECT_ATTACHED_POINT ]);
                integer attPt = llList2Integer(od, 1);
                tawk("  " + (string) (i + 1) + ".  " + llList2String(od, 0) +
                        " Att: " + (string) attPt +
                        " " + attPoint(attPt));
            }

        //  Avatar                  List avatar information

        } else if (abbrP(command, "av")) {
            key okey = llGetOwnerKey(llGetKey());
            list od = llGetObjectDetails(okey,
                [ OBJECT_NAME,
                  OBJECT_RUNNING_SCRIPT_COUNT, OBJECT_TOTAL_SCRIPT_COUNT,
                    OBJECT_SCRIPT_MEMORY, OBJECT_SCRIPT_TIME,
                  OBJECT_SERVER_COST, OBJECT_STREAMING_COST, OBJECT_PHYSICS_COST,
                  OBJECT_RENDER_WEIGHT, OBJECT_HOVER_HEIGHT, OBJECT_BODY_SHAPE_TYPE,
                  OBJECT_ROOT,
                  OBJECT_POS, OBJECT_ROT ]);
            key seat = llList2Key(od, 11);
            string sitting = "";
            if (seat != okey) {
                sitting = "  Sitting on: " + llKey2Name(seat) + "\n";
            }

            string U_deg = llUnescapeURL("%C2%B0");     // U+00B0 Degree Sign
            vector fwd = llRot2Fwd(llList2Rot(od, 13));
            float abear = PI_BY_TWO - llAtan2(fwd.y, fwd.x);
            abear = abear * RAD_TO_DEG;
            if (abear < 0) {
                abear = 360 + abear;
            }

            tawk("Avatar status:\n" +
                 "  Name: " + llList2String(od, 0) + "\n" +
                 "  Scripts: Running " + (string) llList2Integer(od, 1) +
                    "  Total " + (string) llList2Integer(od, 2) +
                    "  Memory " + (string) llList2Integer(od, 3) +
                    "  Time " + eff(llList2Float(od, 4)) + "\n" +
                 "  Cost: Server " + eff(llList2Float(od, 5)) +
                    "  Streaming " + eff(llList2Float(od, 6)) +
                    "  Physics " + eff(llList2Float(od, 7)) + "\n" +
                 "  Complexity: " + (string) llList2Integer(od, 8) + "\n" +
                 sitting +
                 "  Hover height: " + eff(llList2Float(od, 9)) + "\n" +
                 "  Body shape: " + eff(llList2Float(od, 10)) + "\n" +
                 "  Position: " + efv(llList2Vector(od, 12)) +
                    "  Bearing: " + (string) llRound(abear) + U_deg +
                    " (" + cardinalPoint(abear) + ")\n" +
                 "  Terrain: Ground " + eff(llGround(ZERO_VECTOR)) +
                    " m  Water " + eff(llWater(ZERO_VECTOR)) + " m");

        //  Help                    Print command summary

        } else if (abbrP(command, "he")) {
            llGiveInventory(id, helpFileName);      // Give requester the User Guide notecard

        //  Parcel                  Parcel information

        } else if (abbrP(command, "pa")) {
            vector p = llGetPos();
            list pd = llGetParcelDetails(p,
                [ PARCEL_DETAILS_NAME, PARCEL_DETAILS_DESC,
                  PARCEL_DETAILS_OWNER, PARCEL_DETAILS_AREA ]);
            integer pflags = llGetParcelFlags(p);
            string pft = parcelFlags(pflags);
            string powner = llKey2Name(llList2Key(pd, 2));
            if (powner == "") {
                powner = (string) llList2Key(pd, 2);
            }

            tawk("Parcel information:\n" +
                "  Name: " + llList2String(pd, 0) + "\n" +
                "  Description: " + llList2String(pd, 1) + "\n" +
                "  Owner: " + powner + "\n" +
                "  Area: " + (string) llList2Integer(pd, 3) + " m²\n" +
                "  Primitives: " + (string) llGetParcelPrimCount(p,
                    PARCEL_COUNT_TOTAL, FALSE) + " of " +
                    (string) llGetParcelMaxPrims(p, FALSE) + " maximum\n" +
                "  Flags: " + (string) pflags + pft);

        //  Region                  Region information

        } else if (abbrP(command, "re")) {
            vector gridloc = llGetRegionCorner() / 256;
            integer rflags = llGetRegionFlags();
            string rft = regionFlags(rflags);
            string eow = "";

            vector p = llGetPos();
            if (llEdgeOfWorld(p, <0, 1, 0>)) {
                eow += "North ";
            }
            if (llEdgeOfWorld(p, <1, 0, 0>)) {
                eow += "East ";
            }
            if (llEdgeOfWorld(p, <0, -1, 0>)) {
                eow += "South ";
            }
            if (llEdgeOfWorld(p, <-1, 0, 0>)) {
                eow += "West ";
            }
            if (eow == "") {
                eow = "None";
            }

            tawk("Retrieving region information...");
            tawk("Region information:\n" +
                 "  Region: " + llGetRegionName() + "\n" +
                 "  Grid location: <" + (string) llRound(gridloc.x) + ", " +
                    (string) llRound(gridloc.y) + ", 0>\n" +
                 "  Edge of world: " + eow + "\n" +
                 "  Host name: " + llGetSimulatorHostname() + "\n" +
                 "  Frames per second: " + eff(llGetRegionFPS()) + "\n" +
                 "  Time dilation: " + eff(llGetRegionTimeDilation()) + "\n" +
                 "  Region flags: " + (string) rflags + rft + "\n" +
                 "  Agents in region: " + (string) llGetRegionAgentCount() + "\n" +
                 "  Wind: " + efv(llWind(ZERO_VECTOR)));
            tawk("  Environment:\n" +
                 "  Agent limit: " + env("agent_limit") + "\n" +
                 "  Dynamic pathfinding: " + env("dynamic_pathfinding") + "\n" +
                 "  Estate ID: " + env("estate_id") + "\n" +
                 "  Estate name: " + env("estate_name") + "\n" +
                 "  Frame number: " + env("frame_number") + "\n" +
                 "  Regions per CPU: " + env("region_cpu_ratio") + "\n" +
                 "  Region idle: " + env("region_idle") + "\n" +
                 "  Region type: " + env("region_product_name") + "\n" +
                 "  Region SKU: " + env("region_product_sku") + "\n" +
                 "  Start time: " +
                        eDate(UnixTime2List((integer) env("region_start_time"))) + "\n" +
                 "  Sim channel: " + env("sim_channel") + "\n" +
                 "  Sim version: " + env("sim_version") + "\n" +
                 "  Host name: " + env("simulator_hostname") + "\n" +
                 "  Max prims: " + env("region_max_prims") + "\n" +
                 "  Bonus factor: " + env("region_object_bonus") + "\n" +
                 "  Whisper range: " + env("whisper_range") + "\n" +
                 "  Chat range: " + env("chat_range") + "\n" +
                 "  Shout range: " + env("shout_range"));

        //  Status                  Print status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();
            tawk(llGetScriptName() + " status:\n" +
                 "    Script memory.  Free: " + (string) mFree +
                 "    Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)"
                );
        }
        return TRUE;
    }

    //  env  --  Get environment variable

    string env(string var) {
        return llGetEnv(var);
    }

    //  UnixTime2List  --  Decode Unix time to [ YYYY, MM, DD, hh, mm, ss ]

    list UnixTime2List(integer vIntDat) {
        if (vIntDat / 2145916800) {
            vIntDat = 2145916800 * (1 | vIntDat >> 31);
        }
        integer vIntYrs = 1970 + ((((vIntDat %= 126230400) >> 31) +
                          vIntDat / 126230400) << 2);
        vIntDat -= 126230400 * (vIntDat >> 31);
        integer vIntDys = vIntDat / 86400;
        list vLstRtn = [ vIntDat % 86400 / 3600,
                         vIntDat % 3600 / 60,
                         vIntDat % 60 ];

        if (789 == vIntDys) {
            vIntYrs += 2;
            vIntDat = 2;
            vIntDys = 29;
        } else {
            vIntYrs += (vIntDys -= (vIntDys > 789)) / 365;
            vIntDys %= 365;
            vIntDys += vIntDat = 1;
            integer vIntTmp;
            while (vIntDys > (vIntTmp = (30 | (vIntDat & 1) ^
                    (vIntDat > 7)) - ((vIntDat == 2) << 1))) {
                vIntDat++;
                vIntDys -= vIntTmp;
            }
        }
        return [ vIntYrs, vIntDat, vIntDys ] + vLstRtn;
    }

    //  Edit integer to two digit string with leading zero

    string lz2(integer n) {
        string sn = (string) n;
        if (n < 10) {
            sn = "0" + sn;
        }
        return sn;
    }

    string eDate(list ld) {
        return ((string) llList2Integer(ld, 0)) + "-" +
               lz2(llList2Integer(ld, 1)) + "-" +
               lz2(llList2Integer(ld, 2)) + " " +
               lz2(llList2Integer(ld, 3)) + ":" +
               lz2(llList2Integer(ld, 4)) + ":" +
               lz2(llList2Integer(ld, 5));
    }

    default {

        on_rez(integer start_param) {
            owner = llGetOwner();
        }

        state_entry() {
            whoDat = owner = llGetOwner();
        }

        //  Process messages from other scripts

        link_message(integer sender, integer num, string str, key id) {

            //  LM_AU_COMMAND (81): Process command

            if (num == LM_AU_COMMAND) {
                processAuxCommand(id, llJson2List(str));
            }
        }

        /*  The run_time_permissions() event is received when we are
            granted permissions for PERMISSION_TRIGGER_ANIMATION.  We
            then make the request we're now permitted to submit.  */

        run_time_permissions(integer perm) {

            if (perm & PERMISSION_TRIGGER_ANIMATION) {
                if (reqAnim != "") {
                    llStartAnimation(reqAnim);
                    runAnim = reqAnim;
                    reqAnim = "";
                    relAnim = TRUE;             // Set waiting to release animation
                    llSetTimerEvent(5);         // Start timer to release animation
                }
            }
        }

        //  The timer is used to stop running animations

        timer() {
            if (relAnim) {
                //  Timed stop of running animation
                relAnim = FALSE;
                if (runAnim != "") {
                    llStopAnimation(runAnim);
                    runAnim = "";
                    llSetTimerEvent(0);
                }
            }
        }
    }
