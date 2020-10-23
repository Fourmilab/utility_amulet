    /*
                                Welcome

        This script periodically queries the identities of avatars
        on the parcel where it is present.  It then looks up the
        corresponding user name and logs the arrival.  At each poll
        the list of avatars present at the last poll is compared
        with the new list and departures are logged.  An avatar which
        arrives and departs (or departs and returns) between two polls
        will not be logged.

        If thisLandIsMyLand, arrival and departure monitoring is only
        done when thie object containing this script is over the
        owner's land.  This allows its use in attachments and objects
        such as vehicles which may visit other territory where the
        user isn't concerned with arrivals and departures.

    */

    string module = "Welcome";          // Module name
    integer POLL_USERS = 20;            // Frequency of poll for users (seconds)

    key owner;                          // Owner (wearer) of amulet

    list currentPop = [ ];              // Current population of parcel
    list knownUsers = [ ];              // Known users: ID, name, time entered

    /*  Command channel in chat.  To disable submission of
        commands via chat, and accept them only via the
        LM_AU_COMMAND link message, set commandChannel to 0.  */
    integer commandChannel = 0;         // Command channel in chat
    integer commandH;                   // Handle for command channel

    integer thisLandIsMyLand = TRUE;    // Only poll when on my land
    integer onMyLand;                   // Are we on my land ?

    //  Link messages

    //  Greet module
    integer LM_GR_INIT = 30;        // Re-initialise greet module
    integer LM_GR_STAT = 31;        // Print greet status
    integer LM_GR_ARRIVAL = 32;     // Arrival of avatar
    integer LM_GR_DEPARTURE = 33;   // Departure of avatar

    //  Auxiliary script messages
    integer LM_AU_COMMAND = 81; // Process command

    //  ZEROFILL  --  Edit an integer with leading zeroes

    string zerofill(integer n, integer places) {
        string sn = (string) n;
        while (llStringLength(sn) < places) {
            sn = "0" + sn;
        }
        return sn;
    }

    //  EDDATE  --  Obtain timestamp and edit date into our format

    string eddate() {
        list t = llParseString2List(llGetTimestamp(), ["-", "T", ":", "."], []);

        return zerofill(llList2Integer(t, 0), 4) + "-" +
               zerofill(llList2Integer(t, 1), 2) + "-" +
               zerofill(llList2Integer(t, 2), 2) + " " +
               zerofill(llList2Integer(t, 3), 2) + ":" +
               zerofill(llList2Integer(t, 4), 2) + ":" +
               zerofill(llList2Integer(t, 5), 2);
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  kName  --  Get name for key of user on parcel

    string kName(key k) {
        string name = llKey2Name(k);
        //  If user has the ironic last name of "Resident", elide it
        if (llGetSubString(name, -9, -1) == " Resident") {
            name = llGetSubString(name, 0, llStringLength(name) - 10);
        }
        return name;
    }

    //  POLLUSERS  --  Periodic poll of users on parcel

    pollUsers(integer initscan) {

        if (thisLandIsMyLand && (!llOverMyLand(owner))) {
            //  Don't poll except when over land I own
            if (onMyLand) {
                currentPop = [ ];
                /*  Forget knownUsers when we leave our land.  This
                    requires looking them up again when we return, but
                    avoids the possibility of script crashes due to the
                    list's growing too large.  */
                knownUsers = [ ];
                onMyLand = FALSE;
            }
            return;
        }

        string tdate = eddate();
        integer changes = 0;

        //  If returning to my land after an absence, perform initial scan

        if (!onMyLand) {
            onMyLand = TRUE;
            initscan = TRUE;
        }

        //  Get list of IDs currently on parcel
        list whodat = llGetAgentList(AGENT_LIST_PARCEL, []);

        /*  The first step is to walk through the agent list and
            remove any IDs which were in the currentPop list on
            the last poll but have since left.  */

        integer i;
        for (i = 0; i < llGetListLength(currentPop); i++) {
            key k = llList2Key(currentPop, i);
            integer idx = llListFindList(whodat, [ k ]);
            if (idx < 0) {
                integer j;
                integer found = FALSE;
                for (j = 0; !found && (j < llGetListLength(knownUsers)); j += 3) {
                    if (llList2Key(knownUsers, j) == k) {
                        /* IF LOG
                        logUserEvent("Departure", k, llList2String(knownUsers, j + 1), tdate);
                        /* END LOG */
                        llMessageLinked(LINK_THIS, LM_GR_DEPARTURE,
                            llList2String(knownUsers, j + 1), k);
                        changes++;
                        found = TRUE;
                    }
                }
                //  Remove this ID from the currentPop list
                currentPop = llDeleteSubList(currentPop, i, i);
            }
        }

        /*  Now we perform the complementary operation: walk
            through the whodat list and see if it contains any
            IDs which are not in currentPop.  Each one is a user
            who arrived since the last poll.  Add the ID to
            currentPop and log the arrival.

            Note that even though we can get the user name of
            a user in the region from its key via llKey2Name(),
            we need to maintain the list of knownUsers in order
            to obtain the name when the user departs.  After
            leaving the region llKey2Name() will no longer work.
            Maintaining our own list of known names avoids all of
            the asynchronous rigmarole of making a dataserver
            request to look up the name from the key.  */

        for (i = 0; i < llGetListLength(whodat); i++) {
            key k = llList2Key(whodat, i);
            integer idx = llListFindList(currentPop, [ k ]);
            if (idx < 0) {
                //  Add this ID to the currentPop list
                currentPop += k;
                integer found = FALSE;
                integer j;
                for (j = 0; !found && (j < llGetListLength(knownUsers)); j += 3) {
                    if (llList2Key(knownUsers, j) == k) {
                        if (!initscan) {
                            /* IF LOG
                            logUserEvent("Arrival", k, llList2String(knownUsers, j + 1), tdate);
                            /* END LOG */
                            llMessageLinked(LINK_THIS, LM_GR_ARRIVAL,
                                llList2String(knownUsers, j + 1), k);
                            changes++;
                        }
                        found = TRUE;
                        /*  Since this is an arrival of a user we already
                            know, we need to update the arrival time in
                            the knownUsers table.  This is used when
                            showing the most recent arrival time in the
                            population list.  */
                        knownUsers = llListReplaceList(knownUsers, [ tdate ], j + 2, j + 2);
                    }
                }
                if (!found) {
                    string aname = kName(k);
                    knownUsers += [ k, aname, tdate ];
                    if (!initscan) {
                        /* IF LOG
                        logUserEvent("Arrival", k, aname, tdate);
                        /* END LOG */
                        llMessageLinked(LINK_THIS, LM_GR_ARRIVAL, aname, k);
                    }
                }
                changes++;
            }
        }
    }

    /* IF LOG
    //  LOGUSEREVENT  --  Enter an event into the log

    logUserEvent(string what, key ID, string userName, string timeStamp) {
    }
    /* END LOG */

    /*  PRESENT  --  Compose a message, limited to maxmsg characters,
                     showing as many of users present on the property
                     as fit in that length.  */

    string present(integer maxmsg) {
        string r = "";
        integer popl = llGetListLength(currentPop);
        integer popi = 0;

        integer fits = TRUE;

        while (fits) {
            string s;
            key k = llList2Key(currentPop, popi);

            /*  Look up the user from the UUID.  If we haven't yet completed
                the look-up, ignore this user for the moment.  */

            integer found = FALSE;
            integer j;
            for (j = 0; !found && (j < llGetListLength(knownUsers)); j += 3) {
                if (llList2Key(knownUsers, j) == k) {
                    s = llList2String(knownUsers, j + 1);
                    s += " (" + llList2String(knownUsers, j + 2) + ")";
                    found = TRUE;
                }
            }
            if (found) {
                s = s + "\n";
                if ((llStringLength(r) + llStringLength(s)) > maxmsg) {
                    fits = FALSE;
                } else {
                    r = s + r;
                }
            }
            popi++;
            if (popi > (popl - 1)) {
                fits = FALSE;
            }
        }

        return r;
    }

    //  resetGreet  --  Reset the greet module

    resetGreet() {
        currentPop = [ ];           // Current population of parcel
        knownUsers = [ ];           // Known users: ID, name, time entered
        /* IF LOG
        logUserEvent("Reset", (key) "", "", eddate());
        /* END LOG */
    }

    //  showStatus  --  Show status

    showStatus(key id) {
        integer mFree = llGetFreeMemory();
        integer mUsed = llGetUsedMemory();
        llRegionSayTo(id, PUBLIC_CHANNEL,
            llGetScriptName() + " status:\n" +
            "  currentPop: " + llList2CSV(currentPop) + "\n" +
            "  knownUsers: " + llList2CSV(knownUsers) + "\n" +
            "  Script memory.  Free: " + (string) mFree +
            "  Used: " + (string) mUsed + " (" +
                (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)");
    }

    //  processAuxCommand  --  Process a command

    integer processAuxCommand(key id, list args) {
        string lmessage = llList2String(args, 1);
        args = llDeleteSubList(args, 0, 1);
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command

        //  If the command is preceded by the module name, ignore the prefix
        if (abbrP(command, llToLower(llGetSubString(module, 0, 1))) && (argn > 1)) {
            args = llList2List(args, 1, -1);
            command = llList2String(args, 0);
            argn--;
        } else {
            /*  If commandChannel is zero, silently ignore commands which
                not directed to us by being prefixed with the module name.  */
            if (commandChannel == 0) {
                return TRUE;
            }
        }

        //  Status              Show general status

        if (abbrP(command, "st")) {
            showStatus(id);

        //  Forget             Forget non-owner avatars on parcel

        } else if (abbrP(command, "fo")) {
            integer i;
            integer n = llGetListLength(currentPop);

            for (i = 0; i < n; i++) {
                if (llList2Key(currentPop, i) != owner) {
                    currentPop = llDeleteSubList(currentPop, i, i);
                    i--;
                    n--;
                }
            }

        //  Present             Show avatars on parcel

        } else if (abbrP(command, "pr")) {
            llRegionSayTo(id, PUBLIC_CHANNEL, llGetSubString(present(1000), 0, -2));

        //  Reset               Reset current population and log

        } else if (abbrP(command, "re")) {
            if (id == owner) {
                resetGreet();
                llRegionSayTo(id, PUBLIC_CHANNEL, "Reset.");
            } else {
                llRegionSayTo(id, PUBLIC_CHANNEL, "Only owner can reset.");
            }
        } else {
            llRegionSayTo(id, PUBLIC_CHANNEL, "Huh?  Unknown command \"" + lmessage + "\".");
        }
        return TRUE;
    }

    default {

        on_rez(integer start) {
            llResetScript();
        }

        state_entry() {
            owner = llGetOwner();

            onMyLand = llOverMyLand(owner);
            pollUsers(TRUE);                // Do an immediate poll

            llSetTimerEvent(POLL_USERS);    // Start poll timer

            if (commandChannel != 0) {
                commandH = llListen(commandChannel, "", NULL_KEY, ""); // Listen on command chat channel
                llOwnerSay(module + " listening on /" + (string) commandChannel);
            }
            /* IF LOG
            logUserEvent("Restart", (key) "", "", eddate());
            /* END LOG */
        }

        //  The timer is used for periodic polls for changes in population

        timer() {
            pollUsers(FALSE);
        }

        /*  The listen event receives and processes messages from
            local chat.  */

        listen(integer channel, string name, key id, string message) {
            string lmessage = llToLower(llStringTrim(message, STRING_TRIM));
            list args = llParseString2List(lmessage, [" "], []);    // Command and arguments

            processAuxCommand(id, [ message, lmessage ] + args);
        }

        /*  The link_message() event receives commands from other scripts
            and passes them on to the command processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {

            //  LM_GR_INIT (30): Initialise greet module

            if (num == LM_GR_INIT) {
                resetGreet();

            //  LM_GR_STAT (31): Show status of greet module

            } else if (num == LM_GR_STAT) {
                showStatus(id);

            //  LM_AU_COMMAND (81): Process command

            } else if (num == LM_AU_COMMAND) {
                processAuxCommand(id, llJson2List(str));
            }
        }
    }
