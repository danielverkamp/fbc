OPTION EXPLICIT

DIM depth(3) AS INTEGER
DIM key AS STRING, driver AS STRING
DIM AS INTEGER i, j, w, h, d

depth(0) = 8
depth(1) = 16
depth(2) = 32

FOR i = 0 to 2
	SCREEN 14, depth(i)
	SCREENINFO w, h, d,,,driver
	LOCATE 1: PRINT "Mode: " + STR$(w) + "x" + STR$(h) + "x" + STR$(d);
	PRINT " (" + driver + ")"
	IF (i = 0) THEN
		FOR j = 0 TO 255: LINE(32+j, 100)-(32+j, 139), j : NEXT
	ELSE
		FOR j = 0 TO 255
			LINE(32+j, 40)-(32+j, 79), j SHL 16
			LINE(32+j, 100)-(32+j, 139), j SHL 8
			LINE(32+j, 160)-(32+j, 199), j
		NEXT
	END IF
	key = INKEY$
	WHILE key = "": key = INKEY$: WEND
	IF key = CHR$(255) + "X" THEN END
NEXT i
