##
##
## This is to read struct definition and create argument list
## that could be given to printf.
##



BEGIN {

namere = "[A-Z][^ [;]+"

pre = "Data->"
post = ", "


finalout = ""



}



// {

yes = match($0, namere)
if ( !yes ) {
    printf("==Name of var not found==\n")
    next
}


# Find what we got 
# note the regex: the pattern has to be word that can appear at start of line.
unsig = match($0, /[ ^]unsigned /)

char = match($0, /[ ^]char /)
integ = match($0, /[ ^]int /)
short = match($0, /[ ^]short /)
flt = match($0, /[ ^]float /)

array = match($0, /\[[0-9]*\]/)
if (array) {
    after = substr($0, RSTART + RLENGTH)
    arraydouble = match(after, /\[[0-9]*\]/)
    if (arraydouble)
        print "multidim"
}

# Custom data types
arincpos = match($0, /[ ^]ARINC_Position /) 



# debug: print each line and what it matches
#print $0
#print unsig "  " array "  " char "  " integ "  "  short "  "  flt "   "  arincpos
#print "\n\n"


# set spec to none, so we can test if it was assigned
spec = ""


# Get conversion specifier
if (arincpos) {
join = post pre
copy = $0
sub(/ARINC_Position/, "", copy)
match(copy, namere)
# add a . to the name, since we will need items from the struct
name = substr(copy, RSTART, RLENGTH) "."
spec = sprintf("%s%s%s%s%s%s%s%s%s%s%s%s", pre, name, "Lat_Letter", join, name, "Latitude", join, name, "Lon_Letter", join, name, "Longitude", post)
}

else if ( (unsig || char || short || integ || flt) && ! arraydouble) {
match($0, namere)
spec = substr($0, RSTART, RLENGTH)
spec = sprintf("%s%s%s", pre, spec, post)
}

else if ( arraydouble ) {
# get array name
match($0, namere)
arrayname = substr($0, RSTART, RLENGTH)

# get number of rows
match($0, /\[[0-9]*\]/)
rows = substr($0, RSTART + 1, RLENGTH - 2)

# create argument format
for (i = 0; i < rows; i++) {
    spec = spec sprintf("%s%s[%d]%s", pre, arrayname, i, post)
}

}


# set default if nothing was assigned
if ( length(spec) < 2 ) 
spec = sprintf("==%s==", $0)

finalout = finalout sprintf("%s", spec)
}


END {

# what ever it was and a new line
replace = "\& \n"

# we will be searching for this
regex_string = "([^,]*Data->[^,]+,)"  

copy = finalout
numconv = gsub(/Data->/, "", copy)

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
newline = newline "\n"

print newline
}

