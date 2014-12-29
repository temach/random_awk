##
## This is to read struct declaration that is made up of 
## basic types and create a string to print the structure 
## 
## The string is terminated with ); to make it a valid SQL query
## Also every 10 specifiers a new line is inserted to make it easier to read
##


BEGIN {

# all conversion specifiers need to have a comma and a space at the end. Nothing more!
# these last two chars ", " will get deleted and replaced with ");" to make a good query


uintf = "%u, "

intf = "%i, "
shortf = intf
ucharf = intf

charf = "'%c', "
fltf = "%f, "

stringf = "\\\"%s\\\", "

lc = 0

finalout = ""

}


// {

# Find what we got
unsig = match($0, /[ ^]unsigned /)

char = match($0, /[ ^]char /)
integ = match($0, /[ ^]int /)
short = match($0, /[ ^]short /)
flt = match($0, /[ ^]float /)
dbl = match($0, /[ ^]double /)

string = (char && ! unsig)

array = match($0, /\[.?.?.?\]/)
if (array) {
    after = substr($0, RSTART + RLENGTH)
    arraydouble = match(after, /\[[0-9]*\]/)
    if (arraydouble) {
        array = 0       # if its a double array then don't act like its a simple array
        print "multidim"
    }
}

arincpos = match($0, /[ ^]ARINC_Position /) 



# debug: print each line and what it matches
# print $0
# print unsig "  " array "  " char "  " integ "  "  short "  "  flt "   "  arincpos
# print "\n\n"


# Get conversion specifier
if (array && string)
spec = stringf

else if (unsig && (char || integ || short))
spec = uintf

else if (char)
spec = charf

else if (integ || short)
spec = intf

else if (flt || dbl)
spec = fltf

else if (arincpos) {
spec = sprintf("%s%s%s%s", charf, fltf, charf, fltf)
lc += 3
}

else 
spec = sprintf("==%s==", $0)


# The type is determined. But if its an array we 
# still have some work to do! Because items from 
# the array might need to be printed separately 


# if its a 2D array of strings
if (arraydouble && string) {
# get number of rows
match($0, /\[[0-9]*\]/)
rows = strtonum( substr($0, RSTART + 1, RLENGTH - 2) )

# create argument format
for (i = 0; i < rows; i++)
    spec = sprintf("%s%s", spec, stringf)

}

 
# So its its an array but NOT of chars (so its not a string)
if (array && ! string) {

# get number of rows
match($0, /\[[0-9]*\]/)
rows = strtonum( substr($0, RSTART + 1, RLENGTH - 2) )

arrayitem = spec

# zero the spec and recompose it differently
spec = ""

# create argument format
for (i = 0; i < rows; i++)
    spec = sprintf("%s%s", spec, arrayitem)

# end the if (array && ! string) block
}



# Now we finally have our string, add it to the bigger string
finalout = finalout sprintf("%s", spec)

}

END {


# what ever it was and a new line
replace = "\& \"\n\""

# we will be searching for this
regex_string = "([^,]*%[^,]+,)"  

copy = finalout
numconv = gsub(/%/, "", copy)

# set what will be the result to the input
newline = finalout

# ON Query
i = 1
while (numconv > 10) {
    newline = gensub(regex_string, replace, i * 10, newline)
    numconv -= 10   
    i++
}

len = length(newline)
newline = substr(newline, 0, len - 2)
newline = newline ");\n"

print newline
}

