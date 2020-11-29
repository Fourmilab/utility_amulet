     /*

                          Utility Amulet
                      Colour System Conversions

                     by John Walker (Fourmilab)

    */

    key owner;                  // Owner/wearer of attachment
    key whoDat = NULL_KEY;      // Avatar who sent command

    string U_deg;               // U+00B0 Degree Sign

    //  CSS colour names and values

    list cssColours = [
        "AliceBlue", 0xF0F8FF, "AntiqueWhite", 0xFAEBD7, "Aqua", 0x00FFFF,
        "Aquamarine", 0x7FFFD4, "Azure", 0xF0FFFF, "Beige", 0xF5F5DC,
        "Bisque", 0xFFE4C4, "Black", 0x000000, "BlanchedAlmond", 0xFFEBCD,
        "Blue", 0x0000FF, "BlueViolet", 0x8A2BE2, "Brown", 0xA52A2A,
        "BurlyWood", 0xDEB887, "CadetBlue", 0x5F9EA0, "Chartreuse", 0x7FFF00,
        "Chocolate", 0xD2691E, "Coral", 0xFF7F50, "CornflowerBlue", 0x6495ED,
        "Cornsilk", 0xFFF8DC, "Crimson", 0xDC143C, "Cyan", 0x00FFFF,
        "DarkBlue", 0x00008B, "DarkCyan", 0x008B8B, "DarkGoldenRod", 0xB8860B,
        "DarkGray", 0xA9A9A9, "DarkGrey", 0xA9A9A9, "DarkGreen", 0x006400,
        "DarkKhaki", 0xBDB76B, "DarkMagenta", 0x8B008B, "DarkOliveGreen", 0x556B2F,
        "DarkOrange", 0xFF8C00, "DarkOrchid", 0x9932CC, "DarkRed", 0x8B0000,
        "DarkSalmon", 0xE9967A, "DarkSeaGreen", 0x8FBC8F, "DarkSlateBlue", 0x483D8B,
        "DarkSlateGray", 0x2F4F4F, "DarkSlateGrey", 0x2F4F4F, "DarkTurquoise", 0x00CED1,
        "DarkViolet", 0x9400D3, "DeepPink", 0xFF1493, "DeepSkyBlue", 0x00BFFF,
        "DimGray", 0x696969, "DimGrey", 0x696969, "DodgerBlue", 0x1E90FF,
        "FireBrick", 0xB22222, "FloralWhite", 0xFFFAF0, "ForestGreen", 0x228B22,
        "Fuchsia", 0xFF00FF, "Gainsboro", 0xDCDCDC, "GhostWhite", 0xF8F8FF,
        "Gold", 0xFFD700, "GoldenRod", 0xDAA520, "Gray", 0x808080,
        "Grey", 0x808080, "Green", 0x008000, "GreenYellow", 0xADFF2F,
        "HoneyDew", 0xF0FFF0, "HotPink", 0xFF69B4, "IndianRed", 0xCD5C5C,
        "Indigo", 0x4B0082, "Ivory", 0xFFFFF0, "Khaki", 0xF0E68C,
        "Lavender", 0xE6E6FA, "LavenderBlush", 0xFFF0F5, "LawnGreen", 0x7CFC00,
        "LemonChiffon", 0xFFFACD, "LightBlue", 0xADD8E6, "LightCoral", 0xF08080,
        "LightCyan", 0xE0FFFF, "LightGoldenRodYellow", 0xFAFAD2, "LightGray", 0xD3D3D3,
        "LightGrey", 0xD3D3D3, "LightGreen", 0x90EE90, "LightPink", 0xFFB6C1,
        "LightSalmon", 0xFFA07A, "LightSeaGreen", 0x20B2AA, "LightSkyBlue", 0x87CEFA,
        "LightSlateGray", 0x778899, "LightSlateGrey", 0x778899, "LightSteelBlue", 0xB0C4DE,
        "LightYellow", 0xFFFFE0, "Lime", 0x00FF00, "LimeGreen", 0x32CD32,
        "Linen", 0xFAF0E6, "Magenta", 0xFF00FF, "Maroon", 0x800000,
        "MediumAquaMarine", 0x66CDAA, "MediumBlue", 0x0000CD, "MediumOrchid", 0xBA55D3,
        "MediumPurple", 0x9370DB, "MediumSeaGreen", 0x3CB371, "MediumSlateBlue", 0x7B68EE,
        "MediumSpringGreen", 0x00FA9A, "MediumTurquoise", 0x48D1CC, "MediumVioletRed", 0xC71585,
        "MidnightBlue", 0x191970, "MintCream", 0xF5FFFA, "MistyRose", 0xFFE4E1,
        "Moccasin", 0xFFE4B5, "NavajoWhite", 0xFFDEAD, "Navy", 0x000080,
        "OldLace", 0xFDF5E6, "Olive", 0x808000, "OliveDrab", 0x6B8E23,
        "Orange", 0xFFA500, "OrangeRed", 0xFF4500, "Orchid", 0xDA70D6,
        "PaleGoldenRod", 0xEEE8AA, "PaleGreen", 0x98FB98, "PaleTurquoise", 0xAFEEEE,
        "PaleVioletRed", 0xDB7093, "PapayaWhip", 0xFFEFD5, "PeachPuff", 0xFFDAB9,
        "Peru", 0xCD853F, "Pink", 0xFFC0CB, "Plum", 0xDDA0DD,
        "PowderBlue", 0xB0E0E6, "Purple", 0x800080, "RebeccaPurple", 0x663399,
        "Red", 0xFF0000, "RosyBrown", 0xBC8F8F, "RoyalBlue", 0x4169E1,
        "SaddleBrown", 0x8B4513, "Salmon", 0xFA8072, "SandyBrown", 0xF4A460,
        "SeaGreen", 0x2E8B57, "SeaShell", 0xFFF5EE, "Sienna", 0xA0522D,
        "Silver", 0xC0C0C0, "SkyBlue", 0x87CEEB, "SlateBlue", 0x6A5ACD,
        "SlateGray", 0x708090, "SlateGrey", 0x708090, "Snow", 0xFFFAFA,
        "SpringGreen", 0x00FF7F, "SteelBlue", 0x4682B4, "Tan", 0xD2B48C,
        "Teal", 0x008080, "Thistle", 0xD8BFD8, "Tomato", 0xFF6347,
        "Turquoise", 0x40E0D0, "Violet", 0xEE82EE, "Wheat", 0xF5DEB3,
        "White", 0xFFFFFF, "WhiteSmoke", 0xF5F5F5, "Yellow", 0xFFFF00,
        "YellowGreen", 0x9ACD32
    ];

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

    /*                ____ ____ ____
                     / ___/ ___/ ___|
                    | |   \___ \___ \
                    | |___ ___) |__) |
                     \____|____/____/
    */

    /*  css_to_rgb  --  Search the CSS colour database for a match
                        with the given name.  If exact is TRUE, the
                        match must be exact; otherwise, all CSS colours
                        which contain the name, ignoring upper and lower
                        case.  A list is returned containing the full
                        CSS colour name(s) and vectors specifying the
                        RGB components (0 to 1) for the colour(s).
                        If no match is found. an empty list is returned.  */

    vector hex_to_rgb(integer hex) {
        return < ((float) ((hex & 0xFF0000) >> 16)) / 255.0,
                 ((float) ((hex & 0x00FF00) >>  8)) / 255.0,
                 ((float)  (hex & 0x0000FF)       ) / 255.0 >;
    }

    list css_to_rgb(string name, integer exact) {
        list colours;
        integer n = llGetListLength(cssColours);
        integer i;

        if (!exact) {
            name = llToLower(name);
        }

        for (i = 0; i < n; i += 2) {
            string cn = llList2String(cssColours, i);
            if ((exact && (name == cn)) ||
                (!exact && (llSubStringIndex(llToLower(cn), name) >= 0))) {
                colours += [ cn, hex_to_rgb(llList2Integer(cssColours, i + 1)) ];
            }
        }

        return colours;
    }

    /*  rgb_to_css  --  Given an RGB value with components between
                        0 and 1, search the CSS colour name table
                        for matches within a Euclidean distance of
                        epsilon and return a list of matching names
                        and exact RGB values.  */

    list rgb_to_css(vector rgb, float epsilon) {
        list colours;
        integer n = llGetListLength(cssColours);
        integer i;

        for (i = 0; i < n; i += 2) {
            string cn = llList2String(cssColours, i);
            if (llVecDist(rgb, hex_to_rgb(llList2Integer(cssColours, i + 1))) < epsilon) {
                colours += [ cn, hex_to_rgb(llList2Integer(cssColours, i + 1)) ];
            }
        }

        return colours;
    }

    /*               _   _ ______     __
                    | | | / ___\ \   / /
                    | |_| \___ \\ \ / /
                    |  _  |___) |\ V /
                    |_| |_|____/  \_/
    */

    /*  hsv_to_rgb  --  Convert HSV colour values stored in a vector
                        (H = x, S = y, V = z) to RGB (R = x, G = y, B = z).
                        The Hue is specified as a number from 0 to 1
                        representing the colour wheel angle from 0 to 360
                        degrees, while saturation and value are given as
                        numbers from 0 to 1.  */

    vector hsv_to_rgb(vector hsv) {
        float h = hsv.x;
        float s = hsv.y;
        float v = hsv.z;

        if (s == 0) {
            return < v, v, v >;             // Grey scale
        }

        if (h >= 1) {
            h = 0;
        }
        h *= 6;
        integer i = (integer) llFloor(h);
        float f = h - i;
        float p = v * (1 - s);
        float q = v * (1 - (s * f));
        float t = v * (1 - (s * (1 - f)));
        if (i == 0) {
            return < v, t, p >;
        } else if (i == 1) {
            return < q, v, p >;
        } else if (i == 2) {
            return <p, v, t >;
        } else if (i == 3) {
            return < p, q, v >;
        } else if (i == 4) {
            return < t, p, v >;
        } else if (i == 5) {
            return < v, p, q >;
        }
//llOwnerSay("Blooie!  " + (string) hsv);
        return < 0, 0, 0 >;
    }

    /*  rgb_to_hsv  --  Map R, G, B intensities in the range from 0 to 1
                        into Hue, Saturation, and Value: Hue from 0 to 1,
                        Saturation from 0 to 1, and Value from 0 to 1.
                        Special case: if Saturation is 0 (it's a grey
                        scale tone), Hue is undefined and is returned as
                        -1.

                     This follows Foley & van Dam, section 17.4.4.  */

    vector rgb_to_hsv(vector rgb) {
        float imax = rgb.x;
        float imin = rgb.x;

        if (rgb.y > imax) {
            imax = rgb.y;
        }
        if (rgb.z > imax) {
            imax = rgb.z;
        }

        if (rgb.y < imin) {
            imin = rgb.y;
        }
        if (rgb.z < imin) {
            imin = rgb.z;
        }

        float irange = imax - imin;

        vector hsv;

        hsv.z = imax;
        if (imax != 0) {
            hsv.y = irange / imax;
        } else {
            hsv.y = 0;
        }

        if (hsv.y == 0) {
            hsv.x = -1;             // Hue undefined if saturation zero
        } else {
            float rc = (imax - rgb.x) / irange;
            float gc = (imax - rgb.y) / irange;
            float bc = (imax - rgb.z) / irange;
            if (rgb.x == imax) {
                hsv.x = bc - gc;
            } else if (rgb.y == imax) {
                hsv.x = 2 + (rc - bc);
            } else {
                hsv.x = 4 + (gc - rc);
            }
            if (hsv.x < 0) {
                hsv.x += 6;
            }
            hsv.x /= 6;
        }
        return hsv;
    }

    /*               _   _ ____  _
                    | | | / ___|| |
                    | |_| \___ \| |
                    |  _  |___) | |___
                    |_| |_|____/|_____|
    */

    /*  hsl_to_rgb  --  Convert HSL colour specification to RGB
                        intensities.  Hue, Saturation and Lightness as
                        reals from 0 to 1.  The RGB components are
                        returned as reals from 0 to 1. */

    float hslval(float n1, float n2, float hue) {
        if (hue > 1) {
            hue -= 1;
        } else if (hue < 0) {
            hue += 1;
        }
        if (hue < (1.0 / 6.0)) {
            return n1 + (((n2 - n1) * hue) * 6);
        } else if (hue < 0.5) {
            return n2;
        } else if (hue < (2.0 / 3.0)) {
            return n1 + (((n2 - n1) * ((2.0 / 3.0) - hue)) * 6);
        } else {
            return n1;
        }
    }

    vector hsl_to_rgb(vector hsl) {
        vector rgb;

        if (hsl.y == 0) {
            //  Grey scale
            rgb.x = rgb.y = rgb.z = hsl.z;
        } else {
            float m1;
            float m2;

            if (hsl.z <= 0.5) {
                m2 = hsl.z * (1 + hsl.y);
            } else {
                m2 = hsl.z + (hsl.y - (hsl.z * hsl.y));
            }
            m1 = (hsl.z * 2) - m2;
            rgb.x = hslval(m1, m2, hsl.x + (1.0 / 3.0));
            rgb.y = hslval(m1, m2, hsl.x);
            rgb.z = hslval(m1, m2, hsl.x - (1.0 / 3.0));
        }
        return rgb;
    }

    /*  rgb_to_hsl  --  Map R, G, B intensities in the range from 0 to
                        1 into Hue, Saturation, and Lightness: Hue from
                        0 to 1, Saturation from 0 to 1, and Lightness
                        from 0 to 1.  Special case: if Saturation is 0
                        (it's a grey scale tone), Hue is undefined and
                        is returned as -1.

                        This follows Foley & van Dam, section 17.4.5.  */

    vector rgb_to_hsl(vector rgb) {
        float imax = rgb.x;
        float imin = rgb.x;

        if (rgb.y > imax) {
            imax = rgb.y;
        }
        if (rgb.z > imax) {
            imax = rgb.z;
        }

        if (rgb.y < imin) {
            imin = rgb.y;
        }
        if (rgb.z < imin) {
            imin = rgb.z;
        }

        float isum = imax + imin;
        float irange = imax - imin;

        vector hsl;

        hsl.z = isum / 2;
        if (imax == imin) {
            hsl.x = -1;
            hsl.y = 0;
        } else {
            if (hsl.z <= 0.5) {
                hsl.y = irange / isum;
            } else {
                hsl.y = irange / ((2 - imax) - imin);
            }
            float rc = (imax - rgb.x) / irange;
            float gc = (imax - rgb.y) / irange;
            float bc = (imax - rgb.z) / irange;
            if (rgb.x == imax) {
                hsl.x = bc - gc;
            } else if (rgb.y == imax) {
                hsl.x = 2 + (rc - bc);
            } else {
                hsl.x = 4 + (gc - rc);
            }
            if (hsl.x < 0) {
                hsl.x += 6;
            }
            hsl.x /= 6;
        }
        return hsl;
    }

    /*                ____ __  ____   __   ____ __  ____   ___  __
                     / ___|  \/  \ \ / /  / ___|  \/  \ \ / / |/ /
                    | |   | |\/| |\ V /  | |   | |\/| |\ V /| ' /
                    | |___| |  | | | |   | |___| |  | | | | | . \
                     \____|_|  |_| |_|    \____|_|  |_| |_| |_|\_\
    */

    /*  cmy_to_rgb  --  Convert CMY colour specification, C, M, Y
                        ranging from 0 to 1, to R, G, B colour
                        specification, also ranging from 0 to 1.

                        |R|   |1|   |C|
                        |G| = |1| - |M|
                        |B|   |1|   |Y|
    */

    vector cmy_to_rgb(vector cmy) {
        return < 1 - cmy.x, 1 - cmy.y, 1 - cmy.z >;
    }

    vector cmyk_to_rgb(rotation cmyk) {
        float omk = 1 - cmyk.s;

        return < (1 - cmyk.x) * omk,
                 (1 - cmyk.y) * omk,
                 (1 - cmyk.z) * omk >;
    }

    /*  rgb_to_cmy  --  Convert RGB colour specification, R, G, B
                        ranging from 0 to 1, to C, M, Y colour
                        specification, also ranging from 0 to 1.

                        |C|   |1|   |R|
                        |M| = |1| - |G|
                        |Y|   |1|   |B|

                        Note that interconversion of RGB and CMY are
                        inverses of one another and separate functions
                        are not really necessary.  But the extra
                        function takes little extra space and makes
                        things clearer for those writing and reading
                        the code.
    */

    vector rgb_to_cmy(vector rgb) {
        return < 1 - rgb.x, 1 - rgb.y, 1 - rgb.z >;
    }

    rotation rgb_to_cmyk(vector rgb) {
        float k = rgb.x;
        if (rgb.y > k) {
            k = rgb.y;
        }
        if (rgb.z > k) {
            k = rgb.z;
        }
        k = 1 - k;
        float omk = 1 - k;
        if (omk == 0) {
            //  If no black component, don't scale RGB
            omk = 1;
        }
        return < ((1 - rgb.x) - k) / omk,
                 ((1 - rgb.y) - k) / omk,
                 ((1 - rgb.z) - k) / omk,
                 k >;
    }

    /*               _____ _____ __  __ ____
                    |_   _| ____|  \/  |  _ \
                      | | |  _| | |\/| | |_) |
                      | | | |___| |  | |  __/
                      |_| |_____|_|  |_|_|
    */

    /*  temp_to_rgb  --  Black body temperature in degrees Kelvin
                         to RGB.  */

    vector temp_to_rgb(float degk) {
        float temps = degk / 100;
        vector rgb;

        //  Red component
        if (temps <= 66) {
            rgb.x = 1;
        } else {
            rgb.x = clamp(1.292936186 * llPow(temps - 60, -0.1332047592));
        }

        //  Green component
        if (temps <= 66) {
            rgb.y = clamp(0.390081578769 * llLog(temps) - 0.6318414437886);
        } else {
            rgb.y = clamp(1.12989086 * llPow(temps - 60, -0.0755148492));
        }

        //  Blue component
        if (temps < 19) {
            rgb.z = 0;
        } else {
            rgb.z = clamp(0.54320678911 * llLog(temps - 10) - 1.19625408914);
        }

        return rgb;
    }

    /*  rgb_to_temp  --  Approximate colour by colour temperature.
                         This is a tacky thing to do, as many RGB
                         colours are nothing like a black body
                         spectrum.  We just perform a binary search
                         for a temperature whose red/blue ratio
                         approximates that of the input colour.  */

    float rgb_to_temp(vector rgb) {
        float epsilon = 0.4;
        float tmin = 1000;
        float tmax = 40000;
        float ctemp;
        if (rgb.x == 0) {
            //  Avoid divide by zero for no red component colours
            rgb.x = 0.001;
        }
        float br_ratio = rgb.z / rgb.x;

        while ((tmax - tmin) > epsilon) {
            ctemp = (tmin + tmax) / 2;
            vector crgb = temp_to_rgb(ctemp);
            if ((crgb.z / crgb.x) >= br_ratio) {
                tmax = ctemp;
            } else {
                tmin = ctemp;
            }
        }

        return (float) llRound(ctemp);
    }

    /*              __   _____ ___
                    \ \ / /_ _/ _ \
                     \ V / | | | | |
                      | |  | | |_| |
                      |_| |___\__\_\
    */

    /*  rgb_to_yiq  --  Convert RGB colour specification, R, G, B
                        ranging from 0 to 1, to Y, I, Q colour
                        specification.  YIQ is the encoding used in
                        NTSC television.

                        |Y|   |0.2989  0.5866  0.1144|   |R|
                        |I| = |0.5959 -0.2741 -0.3218| . |G|
                        |Q|   |0.2113 -0.5227  0.3113|   |B|
    */

    vector rgb_to_yiq(vector rgb) {
        float ay = (rgb.x * 0.2989) + (rgb.y *  0.5866) + (rgb.z *  0.1144);
        float ai = (rgb.x * 0.5959) + (rgb.y * -0.2741) + (rgb.z * -0.3218);
        float aq = (rgb.x * 0.2113) + (rgb.y * -0.5227) + (rgb.z *  0.3113);
        vector yiq;

        yiq.x = ay;
        if (ay == 1.0) {            // Prevent round-off on grey scale
            ai = aq = 0.0;
        }
        yiq.y = ai;
        yiq.z = aq;
        return yiq;
    }

    /*  yiq_to_rgb  --  Convert YIQ colour specification, Y, I, Q given as
                        reals, Y from 0 to 1, I from -0.6 to 0.6, Q from
                        -0.52 to 0.52, to R, G, B intensities in the range
                        from 0 to 1.  The matrix below is the inverse of
                        the rgb_to_yiq matrix above.  YIQ is the encoding
                        used in NTSC television.

                        |R|   |1.0000  0.9562  0.6210|   |Y|
                        |G| = |1.0000 -0.2717 -0.6485| . |I|
                        |B|   |1.0000 -1.1053  1.7020|   |Q|
    */

    float clamp(float v) {
        if (v > 1) {
            return 1;
        }
        if (v < 0) {
            return 0;
        }
        return v;
    }

    vector yiq_to_rgb(vector yiq) {
        float ar = yiq.x + (yiq.y *  0.9562) + (yiq.z *  0.6210);
        float ag = yiq.x + (yiq.y * -0.2717) + (yiq.z * -0.6485);
        float ab = yiq.x + (yiq.y * -1.1053) + (yiq.z *  1.7020);

        return < clamp(ar), clamp(ag), clamp(ab) >;
    }

    /*              __   ___   ___     __
                    \ \ / / | | \ \   / /
                     \ V /| | | |\ \ / /
                      | | | |_| | \ V /
                      |_|  \___/   \_/
    */

    /*  rgb_to_yuv  --  Convert RGB colour specification, R, G, B
                        ranging from 0 to 1, to Y, U, V colour
                        specification.  YIQ is the encoding used by
                        PAL television.

                        |Y|   | 0.2989  0.5866  0.1144|   |R|
                        |U| = |-0.1473 -0.2891  0.4364| . |G|
                        |V|   | 0.6149 -0.5145 -0.1004|   |B|
    */

    vector rgb_to_yuv(vector rgb) {
        float ay = (rgb.x *  0.2989) + (rgb.y *  0.5866) + (rgb.z *   0.1144);
        float au = (rgb.x * -0.1473) + (rgb.y * -0.2891) + (rgb.z *   0.4364);
        float av = (rgb.x *  0.6149) + (rgb.y * -0.5145) + (rgb.z *  -0.1004);
        vector yuv;

        yuv.x = ay;
        if (ay == 1.0) {            // Prevent round-off on grey scale
            au = av = 0.0;
        }
        yuv.y = au;
        yuv.z = av;
        return yuv;
    }

    /*  yuv_to_rgb  --  Convert YUV colour specification, Y, I, Q given as
                        reals, to R, G, B intensities in the range
                        from 0 to 1.  The matrix below is the inverse of
                        the rgb_to_yuv matrix above.  YUV is the encoding
                        used by PAL television.

                        |R|   |1.0000  0.0000  1.1402|   |Y|
                        |G| = |1.0000 -0.3959 -0.5810| . |U|
                        |B|   |1.0000  2.0294  0.0000|   |V|
    */

    vector yuv_to_rgb(vector yuv) {
        float ar = yuv.x + /* (yuv.y *  0.0000) + */ (yuv.z *  1.1402);
        float ag = yuv.x +    (yuv.y * -0.3959) +    (yuv.z * -0.5810);
        float ab = yuv.x +    (yuv.y *  2.0294) /* + (yuv.z *  0.0000) */;

        return < clamp(ar), clamp(ag), clamp(ab) >;
    }

    //  pColour  --  Show all representations of colour

    pColour(vector rgb) {
        string s;

        s = "\nRGB " + efv(rgb) + "  " +
            "#" + ehexComp(rgb.x) + ehexComp(rgb.y) + ehexComp(rgb.z) + "  " +
            "RGB(" + (string) llRound(rgb.x * 255) + ", " +
                     (string) llRound(rgb.y * 255) + ", " +
                     (string) llRound(rgb.z * 255) + ")  " +
            "RGB(" + (string) llRound(rgb.x * 100) + "%, " +
                     (string) llRound(rgb.y * 100) + "%, " +
                     (string) llRound(rgb.z * 100) + "%)\n";

        vector hsl = rgb_to_hsl(rgb);
        if (hsl.x == -1) {
            hsl.x = 0;              // Call undefined hue 0 to avoid confusion
        }
        s += "HSL " + efv(hsl) + "  HSL" + efvHSx(hsl) + "\n";

        vector hsv = rgb_to_hsv(rgb);
        if (hsv.x == -1) {
            hsv.x = 0;              // Call undefined hue 0 to avoid confusion
        }
        s += "HSV " + efv(hsv) + "  HSV" + efvHSx(hsv) + "\n";

        vector cmy = rgb_to_cmy(rgb);
        rotation cmyk = rgb_to_cmyk(rgb);
        s += "CMY " + efv(cmy) + "  CMYK " + ef((string) cmyk) + "\n";

        vector yiq = rgb_to_yiq(rgb);
        s += "YIQ " + efv(yiq) + "\n";

        vector yuv = rgb_to_yuv(rgb);
        s += "YUV " + efv(yuv) + "\n";

        float tempk = rgb_to_temp(rgb);
        s += "TEMP " + (string) ((integer) tempk) + " " + U_deg + "K";

        list lcss = rgb_to_css(rgb, 0.001);
        integer n = llGetListLength(lcss);
        if (n > 0) {
            s += "\nCSS";
            integer i;
            for (i = 0; i < n; i += 2) {
                s += " " + llList2String(lcss, i) + " " +
                     efv(llList2Vector(lcss, i + 1));
                if (i < (n - 2)) {
                    s += ",";
                }
            }
        }

        tawk(s);
    }

    //  ef  --  Edit floats in string to parsimonious representation

    string efv(vector v) {
        return ef((string) v);
    }

    string efvHSx(vector c) {       // Edit HSV or HSL into degrees and percentages
       return  "(" + (string) llRound(c.x * 360) + U_deg + ", " +
                     (string) llRound(c.y * 100) + "%, " +
                     (string) llRound(c.z * 100) + "%)";
    }

/*
    string eff(float f) {
        return ef((string) f);
    }

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

    //  ehex  --  Edit integer to hexadecimal with leading zeroes

    string ehex(integer i, integer n) {
        string s = "";
        integer j;

        for (j = 0; j < n; j++) {
            s = llGetSubString("0123456789ABCDEF", (i & 0xF), (i & 0xF)) + s;
            i = i >> 4;
        }
        return s;
    }

    //  ehexComp  --  Edit RGB component two two digit hex string

    string ehexComp(float c) {
        return ehex(llRound(c * 255), 2);
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llToLower(llStringTrim(cmd, STRING_TRIM));
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && ((c == ">") || (c == ")"))) {
                inbrack = FALSE;
            }
            if ((c == "<") || (c == "(")) {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    /*  parseCvec  --   Parse a colour vector which may specify a
                        cylindrical colour space specification in
                        terms of degrees and percentages instead of
                        values between 0 and 1.  */

    float parseCvn(string s) {
        string lch = llGetSubString(s, -1, -1);
        if ((lch == "d") || (lch == U_deg)) {
            return ((float) llGetSubString(s, 0, -2)) / 360;
        } else if (lch == "%") {
            return ((float) llGetSubString(s, 0, -2)) / 100;
        }
        return (float) s;
    }

    vector parseCvec(string c) {
        vector cv;

        if ((llGetSubString(c, 0, 0) == "(") &&
            (llGetSubString(c, -1, -1) == ")")) {
            //  Parenthesised vector means components are 0-255
            cv = ((vector) ("<" +  llGetSubString(c, 1, -2) + ">")) / 255;
        } else {
            if ((llSubStringIndex(c, "d") >= 0) ||
                (llSubStringIndex(c, U_deg) >= 0) ||
                (llSubStringIndex(c, "%") >= 0)) {
                list cl = llParseStringKeepNulls(c, [ " ", ",", "<", ">" ], [ ]);
                cv = < parseCvn(llList2String(cl, 1)),
                       parseCvn(llList2String(cl, 2)),
                       parseCvn(llList2String(cl, 3)) >;
            } else {
                cv = (vector) c;
            }
        }
        return cv;
    }

    //  parseCrot  --  Just like parseCvec, but with four component "rotations"

    rotation parseCrot(string c) {
        rotation cr;

        if ((llSubStringIndex(c, "d") >= 0) ||
            (llSubStringIndex(c, U_deg) >= 0) ||
            (llSubStringIndex(c, "%") >= 0)) {
            list cl = llParseStringKeepNulls(c, [ " ", ",", "<", ">" ], [ ]);
            cr = < parseCvn(llList2String(cl, 1)),
                   parseCvn(llList2String(cl, 2)),
                   parseCvn(llList2String(cl, 3)),
                   parseCvn(llList2String(cl, 4)) >;
        } else {
            cr = (rotation) c;
        }
        return cr;
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  processAuxCommand  --  Process a command

    integer processAuxCommand(key id, list margs) {

        whoDat = id;            // Direct chat output to sender of command

        string message = llList2String(margs, 0);
        string lmessage = fixArgs(message);
        list args = llParseString2List(lmessage, [ " " ], []);    // Command and arguments
        string command = llList2String(args, 0);    // The command
        string sparam1 = llList2String(args, 1);    // First argument, for convenience
        string sparam2 = llList2String(args, 2);    // Second argument, for convenience

        //  Colour

        if (abbrP(command, "co")) {

            //  RGB <r, g, b> is synonymous to simple vector
            if (abbrP(sparam1, "rg") &&
                (abbrP(sparam2, "<") || abbrP(sparam2, "(") || abbrP(sparam2, "#"))) {
                sparam1 = sparam2;
            }

            if (abbrP(sparam1, "<") || abbrP(sparam1, "(")) {
                //  <r, g, b> or (r, g, b)
                vector rgb = parseCvec(sparam1);
                pColour(rgb);
            } else if (abbrP(sparam1, "cmyk")) {
                //  CMYK <c, m, y, k>
                rotation cmyk = parseCrot(sparam2);
                pColour(cmyk_to_rgb(cmyk));
            } else if (abbrP(sparam1, "cmy")) {
                //  CMY <c, m, y>
                vector cmy = parseCvec(sparam2);
                pColour(cmy_to_rgb(cmy));
            } else if (abbrP(sparam1, "cs")) {
                //  CSS ["]name["]
                integer exact = FALSE;
                if ((llGetSubString(sparam2, 0, 0) == "\"") &&
                    (llGetSubString(sparam2, -1, -1) == "\"")) {
                    exact = TRUE;
                    args = llParseString2List(message, [ " " ], []);
                    sparam2 = llGetSubString(llList2String(args, 2), 1, -2);
                }
                list cl = css_to_rgb(sparam2, exact);
                integer n = llGetListLength(cl);
                if (n == 0) {
                    tawk("No such CSS colour.");
                } else {
                    if (n == 2) {
                        //  Exactly one match
                        pColour(llList2Vector(cl, 1));
                    } else {
                        integer i;
                        //  List all matches
                        for (i = 0; i < n; i += 2) {
                            tawk("    --  " + llList2String(cl, i) + "  --");
                            pColour(llList2Vector(cl, i + 1));
                        }
                    }
                }
            } else if (abbrP(sparam1, "hsl")) {
                //  HSL <h, s, l>
                vector hsl = parseCvec(sparam2);
                pColour(hsl_to_rgb(hsl));
            } else if (abbrP(sparam1, "hsv")) {
                //  HSV <h, s, v>
                vector hsv = parseCvec(sparam2);
                pColour(hsv_to_rgb(hsv));
            } else if (abbrP(sparam1, "te")) {
                //  TEMP degk
                pColour(temp_to_rgb((float) sparam2));
            } else if (abbrP(sparam1, "yi")) {
                //  YIQ <y, i, q>
                vector yiq = parseCvec(sparam2);
                pColour(yiq_to_rgb(yiq));
            } else if (abbrP(sparam1, "yu")) {
                //  YUV <y, u, v>
                vector yuv = parseCvec(sparam2);
                pColour(yuv_to_rgb(yuv));
            } else if (abbrP(sparam1, "#")) {
                //  #RRGGBB
                integer hex = (integer) ("0x" + llGetSubString(sparam1, 1, -1));
                vector rgb = < ((hex & 0xFF0000) >> 16) / 255.0,
                               ((hex & 0xFF00) >> 8) / 255.0,
                                (hex & 0xFF) / 255.0 >;
                pColour(rgb);
            } else {
                tawk("Don't understand that colour specification.");
            }

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

    default {

        on_rez(integer start_param) {
            owner = llGetOwner();
        }

        state_entry() {
            whoDat = owner = llGetOwner();
            U_deg = llUnescapeURL("%C2%B0");    // U+00B0 Degree Sign
        }

        //  Process messages from other scripts

        link_message(integer sender, integer num, string str, key id) {

            //  LM_AU_COMMAND (81): Process command

            if (num == LM_AU_COMMAND) {
                processAuxCommand(id, llJson2List(str));
            }
        }
    }
