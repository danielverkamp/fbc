'OpenGL texturing
'Relsoft 2004
'Rel.Betterwebber.com
'create texture funk courtesy of lillo


DEFINT A - Z

#define TEX_MASKED      &h1 
#define TEX_MIPMAP      &h2
#DEFINE TEX_NOFILTER    &h4
#DEFINE TEX_HASALPHA    &h8

const PI = 3.141593                     'PI for rotation

option explicit                         'Force declaration

'$include: "GL/gl.bi"                  'OpenGL funks and consts
'$include: "GL/glu.bi"                 'GL standard utility lib


'Declarations
DECLARE SUB Init_GL_SCREEN ()
Declare Sub draw_scene()
Declare Sub Draw_Cube()
Declare function CreateTexture( byval buffer as any ptr, byval flags as integer = 0 ) as GLuint
Declare function load_texture(image_file as string, w as integer, h as integer) as GLuint

'*******************************************************************************************
'Main code
'*******************************************************************************************
    RANDOMIZE TIMER
    dim shared g_texture as GLuint

    Init_GL_SCREEN                          'init GL stuff
    g_texture = load_texture("terrain.bmp", 256, 256)

	do
        draw_scene                          'Draw something
        flip
	loop until Inkey$ <>""


    end



'*******************************************************************************************
'DATA
'*******************************************************************************************
'The cube is defined in the data statements so that it would be easy to manage
'You only have to use a for loop to draw the model

DATA -1.0, -1.0,  1.0
DATA  1.0, -1.0,  1.0
DATA  1.0,  1.0,  1.0
DATA -1.0,  1.0,  1.0

'Back Face
DATA -1.0, -1.0, -1.0
DATA -1.0,  1.0, -1.0
DATA  1.0,  1.0, -1.0
DATA  1.0, -1.0, -1.0

'Top Face
DATA -1.0,  1.0, -1.0
DATA -1.0,  1.0,  1.0
DATA  1.0,  1.0,  1.0
DATA  1.0,  1.0, -1.0

'Bottom Face
DATA -1.0, -1.0, -1.0
DATA  1.0, -1.0, -1.0
DATA  1.0, -1.0,  1.0
DATA -1.0, -1.0,  1.0

'Right face
DATA  1.0, -1.0, -1.0
DATA  1.0,  1.0, -1.0
DATA  1.0,  1.0,  1.0
DATA  1.0, -1.0,  1.0

'Left Face
DATA -1.0, -1.0, -1.0
DATA -1.0, -1.0,  1.0
DATA -1.0,  1.0,  1.0
DATA -1.0,  1.0, -1.0

'Texture coordinates
TEXTURECOORDS:

'Front Face
DATA 0.0, 0.0
DATA 1.0, 0.0
DATA 1.0, 1.0
DATA 0.0, 1.0
'Back Face
DATA 1.0, 0.0
DATA 1.0, 1.0
DATA 0.0, 1.0
DATA 0.0, 0.0
'Top Face
DATA 0.0, 1.0
DATA 0.0, 0.0
DATA 1.0, 0.0
DATA 1.0, 1.0
'Bottom Face
DATA 1.0, 1.0
DATA 0.0, 1.0
DATA 0.0, 0.0
DATA 1.0, 0.0
'Right face
DATA 1.0, 0.0
DATA 1.0, 1.0
DATA 0.0, 1.0
DATA 0.0, 0.0
'Left Face
DATA 0.0, 0.0
DATA 1.0, 0.0
DATA 1.0, 1.0
DATA 0.0, 1.0


'*******************************************************************************************
'SUBS/FUNKS
'*******************************************************************************************

'*******************************************************************************************
'Initializes GL screen
SUB Init_GL_SCREEN()

	'screen information
	dim w as integer, h as integer
    'OpenGL params for gluerspective
	dim FOVy as double            'Field of view angle in Y
	dim Aspect as double          'Aspect of screen
	dim znear as double           'z-near clip distance
	dim zfar as double            'z-far clip distance

    'Set 640*480*32 OpenGL
    screen 18, 32, ,&h2

	'get info of current screen
	screeninfo w, h
    'Set OpenGL ViewPort to screen dimensions
    'using screen info w and h as params
	glViewport 0, 0, w, h

	'Set current Mode to projection(ie: 3d)
	glMatrixMode GL_PROJECTION

    'Load identity matrix to projection matrix
	glLoadIdentity

    'Set gluPerspective params
    FOVy = 80/2                                     '45 deg fovy
    Aspect = w / h                                  'aspect = x/y
    znear = 1                                       'Near clip
    zfar = 200                                      'far clip

    'use glu Perspective to set our 3d frustum dimension up
	gluPerspective FOVy, aspect, znear, zfar

    'Modelview mode
    'ie. Matrix that does things to anything we draw
    'as in lines, points, tris, etc.
	glMatrixMode GL_MODELVIEW
	'load identity(clean) matrix to modelview
	glLoadIdentity

	glShadeModel GL_SMOOTH                 'set shading to smooth(try GL_FLAT)
	glClearColor 0.0, 0.0, 0.0, 1.0        'set Clear color to BLACK
	glClearDepth 1.0                       'Set Depth buffer to 1(z-Buffer)
	glEnable GL_DEPTH_TEST                 'Enable Depth Testing so that our z-buffer works

	'compare each incoming pixel z value with the z value present in the depth buffer
	'LEQUAL means than pixel is drawn if the incoming z value is less than
    'or equal to the stored z value
	glDepthFunc GL_LEQUAL

    'have one or more material parameters track the current color
    'Material is your 3d model
	glEnable GL_COLOR_MATERIAL


    'Enable Texturing
    glEnable GL_TEXTURE_2D


    'Set blending parameters
    glBlendFunc GL_SRC_ALPHA,GL_ONE


	'Tell openGL that we want the best possible perspective transform
	glHint GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST

END SUB


'*******************************************************************************************
'Draw to our open GL screen

Sub draw_scene()

    static theta as single      'Rotation degrees
    dim xtrans   as single      'xtranslation
    dim ytrans   as single      'ytranslation
    dim ztrans   as single      'ztranslation
    dim scalefactor as single   'Scaling factor


    'clear the screen
    'GL_COLOR_BUFFER_BIT = to black(remember glClearColor?)
    'GL_DEPTH_BUFFER_BIT set depth buffer to 1 (remember glClearDepth?)
    glClear  GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT

    glDisable GL_BLEND
	'draw some nifty background
	glPushMatrix

	'move it a lil farther than the cube
    glTranslatef 0, 0, -20
    'scale to fit screen
    glScalef 10, 10, 10

    glRotatef -theta, 0, 0, 1        'rotate in the z axis (Try to REM this)

	'draw the quad
	glBegin GL_QUADS
		glTexCoord2f 0.0, 0.0
		glVertex3f   -1.0, -1.0,  0.0
		glTexCoord2f 1.0, 0.0
		glVertex3f   1.0, -1.0,  0.0
		glTexCoord2f 1.0, 1.0
		glVertex3f   1.0,  1.0,  0.0
		glTexCoord2f 0.0, 1.0
		glVertex3f   -1.0,  1.0,  0.0
	glEnd

	'restore mat
	glPopMatrix


    glEnable GL_BLEND
    'Push matrix to the matrix stack so that we start fresh
    glPushMatrix

    'Reset the matrix to identity
    glLoadIdentity

    'Our translation factor
    'Try to change these arguments
    xtrans = 0.0
    ytrans = 0.0
    ztrans = -10
    glTranslatef xtrans, ytrans, ztrans

    'Our scale factor
    Scalefactor = 1 + (sin(Theta / 100) * 0.5)


    'glScalef scalefactor, scalefactor, scalefactor
    'Scales our modelview matrix 3x in the x, y, z axes
    'try to change its arguments to different values
    glScalef scalefactor, scalefactor, scalefactor


    'glRotatef angle, x, y, z  rotates your model
    'angle = Specifies the angle of rotation, in degrees
    'x, y, z = Specify the x, y, and z coordinates of a vector
    glRotatef theta, 1, 0, 0        'angle, x axis = 1, all other axis are zero
    glRotatef theta, 0, 1, 0        'rotate in the y axis (Try to REM this)
    glRotatef theta, 0, 0, 1        'rotate in the z axis (Try to REM this)


    Draw_Cube

    glPopMatrix
    Theta = theta + 0.4
    'Force completion of drawing
    glFlush
end sub


'*******************************************************************************************
'Draw's our a normalized cube. Taken andmodified from NeHe's tutorials(Im lazy so what? ;*))


Sub Draw_Cube()
        'loop counters
        dim i as integer, j as integer

        'variable to check if colors and cube are already initialized
        static color_init

        'initialize color and cube arrays
        if color_init = 0 then                          'is it initialized already?
                                                            'nope so...
            'make static arrays for cube and colors
            '(23, 2) means 23 vertices and 3 elements per vertex
            '3 because:
            'x, y, z for verts
            'r, g, b for colors
            static colors(23, 2) as GLfloat
            static cube(23, 2) as GLfloat
            static coords(23, 1) as GLfloat

            'put values to each elements by looping
            for i = 0 to 23
                for j = 0 to 2
                    'Color range are from 0 to 1
                    colors(i, j) = rnd          'I'm lazy so I just randomized the colors
                    'read cubes coords from data statements
                    read cube(i,j)
                next i
            next j

            'put values to coords
            Restore TEXTURECOORDS
            for i = 0 to 23
                for j = 0 to 1
                    'read cubes coords from data statements
                    read coords(i,j)
                next i
            next j


            color_init = -1
        end if


        'Draw the cube using VECTOR forms of GL commands
        glBegin GL_QUADS
    		'Draw the cube with smooth colors
   		    for i = 0 to 23
   		    	  	  'unrem if you want to combine colors and texture
		              'glColor3fv   @colors(i,0)   'Pass the addy of first element
		              glTexCoord2fv @coords(i,0)
		              glVertex3fv   @cube(i,0)
		    next i
    	glEnd

End Sub


'*******************************************************************************************
' A function that creates an opengl texture from a GET/PUT array
' nifty funk courtesy of lillo (this function is available on appendix F of gfxlib.txt)
'

	FUNCTION CreateTexture( BYVAL buffer AS ANY PTR, BYVAL flags AS INTEGER _
							= 0 ) AS GLuint
		REDIM dat(0) AS UBYTE
		DIM p AS UINTEGER PTR, s AS USHORT PTR
		DIM AS INTEGER w, h, x, y, col
		DIM tex AS GLuint
		DIM AS GLenum format, minfilter, magfilter
		
		CreateTexture = 0
		
		s = buffer
		w = s[0] SHR 3
		h = s[1]
		
		IF( (w < 64) OR (h < 64) ) THEN
			EXIT FUNCTION
		END IF
		IF( (w AND (w-1)) OR (h AND (h-1)) ) THEN
			'' Width/height not powers of 2
			EXIT FUNCTION
		END IF
		
		REDIM dat(w * h * 4) AS UBYTE
		p = @dat(0)
		
		glGenTextures 1, @tex
		glBindTexture GL_TEXTURE_2D, tex
		
		FOR y = h-1 TO 0 STEP -1
			FOR x = 0 TO w-1
				col = POINT(x, y, buffer)
				'' Swap R and B so we can use the GL_RGBA texture format
				col = RGBA(col AND &hFF, _
						  (col SHR 8) AND &hFF, _
						  (col SHR 16) AND &hFF, _
						  col SHR 24)
				IF( flags AND TEX_HASALPHA ) THEN
					*p = col
				ELSE
					IF( (flags AND TEX_MASKED) AND _
							(col = &hFF00FF) ) THEN
						*p = 0
					ELSE
						*p = col OR &hFF000000
					END IF
				END IF
				p += 4
			NEXT x
		NEXT y
		
		IF( flags AND ( TEX_MASKED OR TEX_HASALPHA ) ) THEN
			format = GL_RGBA
		ELSE
			format = GL_RGB
		END IF
		
		IF( flags AND TEX_NOFILTER ) THEN
			magfilter = GL_NEAREST
		ELSE
			magfilter = GL_LINEAR
		END IF
		
		IF( flags AND TEX_MIPMAP ) THEN
			gluBuild2DMipmaps GL_TEXTURE_2D, format, w, h, GL_RGBA, _
							  GL_UNSIGNED_BYTE, @dat(0)
			IF( flags AND TEX_NOFILTER ) THEN
				minfilter = GL_NEAREST_MIPMAP_NEAREST
			ELSE
				minfilter = GL_LINEAR_MIPMAP_LINEAR
			END IF
		ELSE
			glTexImage2D GL_TEXTURE_2D, 0, format, w, h, 0, GL_RGBA, _
							 GL_UNSIGNED_BYTE, @dat(0)
			minfilter = magfilter
		END IF
		glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minfilter
		glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magfilter
		
		CreateTexture = tex
	
	END FUNCTION

							 
function load_texture(image_file as string, w as integer, h as integer) as GLuint
	dim image(w * h * 2 + 4) as ushort   ' set up a big enough array for our image
	bload image_file, @image(0)			 'load it
	dim ret as GLuint 					 'return value
	'create and bind the texture ( courtesy of lillo )
	ret = CreateTexture(@image(0), TEX_MASKED or TEX_MIPMAP )
	'return value in case we need multiple texture
	load_texture = ret
end function
