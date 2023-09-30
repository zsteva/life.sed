#
#    game of life implemented in sed
#    Copyright (C) 2023 Zeljko Stevanovic <zsteva@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# cleanup line
s/ /./g
s/[^\.]/O/g

# copy line to hold
h

:load

/^start/ {
    # hold -> work
    g
    s/\n/I/g
    s/$/I/
    bstart
}

# cleanup line
s/ /./g
s/[^\.]/O/g

# append to hold
H
# zap load next line
z;n
bload

:start

# add empty 4 cell outside
:appendempty
# copy to hold
h
# select last line
s/^.*I\([^I]*I\)$/\1/
s/O/./g
s/\././g

# duplicate
s/^\(.*\)$/\1\1\1\1/

# append 4 empty line to hold
H
# append hold to 4 empty line
G
# cleanup new lines
s/\n//g

# two empty column left, two empty column right
s/^/..../
s/I/....I..../g
s/I....$/I/

:nextgeneration

# markers:
# I -- row separator
# A -- after cell (y-1)(x)
# C -- after cell (y)(x)
# E -- after cell (y+1)(x)
# F -- current cell (y)(x) in next state part
# Z -- <current state>Z<next state>

# copy begining for next state
s/^\([^I]*I.\)\(.*\)$/\1\2Z\1F/

# init markers for closest cell
s/^\(..\)/\1A/
s/^\([^I]*I.\)\(.\)\(.\)/\1\2C\3/
s/^\([^I]*I[^I]*I..\)/\1E/

:calccell

s/F/GF/

# calculate popularity
/[^\.].A/ { s/F/GF/ }
/[^\.]A/ { s/F/GF/ }
/A[^\.]/ { s/F/GF/ }

/[^\.].C/ { s/F/GF/ }
/C[^\.]/ { s/F/GF/ }

/[^\.].E/ { s/F/GF/ }
/[^\.]E/ { s/F/GF/ }
/E[^\.]/ { s/F/GF/ }


/[^\.]C/ {
    # what happend to live cell?
    s/GGGGGGGGGF/.F/
    s/GGGGGGGGF/.F/
    s/GGGGGGGF/.F/
    s/GGGGGGF/.F/
    s/GGGGGF/.F/
    s/GGGGF/OF/
    s/GGGF/OF/
    s/GGF/.F/
    s/GF/.F/
    bmovemarker
}

/\.C/ {
    # and dead cell
    s/GGGGGGGGGF/.F/
    s/GGGGGGGGF/.F/
    s/GGGGGGGF/.F/
    s/GGGGGGF/.F/
    s/GGGGGF/.F/
    s/GGGGF/OF/
    s/GGGF/.F/
    s/GGF/.F/
    s/GF/.F/
    bmovemarker
}

:movemarker

/E.IZ/ {
    # end scan
    bendmarkermove
}

/C.I/ {
    # move to new row
    s/C\(.\)\(..\)\([^F]*\)F/C\1\2\3\1\2F/
    s/A\(....\)/\1A/
    s/C\(....\)/\1C/
    s/E\(....\)/\1E/

    bcalccell
}

s/A\(.\)/\1A/
s/C\(.\)/\1C/
s/E\(.\)/\1E/

bcalccell

:endmarkermove

# remove markers
s/E//
s/A//
# copy remaind 
s/C\([^Z]*\)Z\([^F]*\)F/\1Z\2\1/

# next state to current
s/^.*Z//

:show
h
# s/Z/======I/

# delete 4 cell outside
:deleteempty
s/^....//
s/....I..../I/g
s/....I$/I/

s/^[^I]*I[^I]*I[^I]*I[^I]*I//
s/[^I]*I[^I]*I[^I]*I[^I]*I$//
# /deleteempty

s/I/\n/g
p
g

# next generation
# read dummy line and ignore it
# save, zap, read, restore
h;z;n;g

bnextgeneration

:end
z
q

