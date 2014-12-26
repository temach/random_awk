##
## This is to read struct declaration that is made up of 
## basic types and create a string to print the structure 
## 
## The string is terminated with ); to make it a valid SQL query
## Also every 10 specifiers a new line is inserted to make it easier to read
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


# Determine type of what we got
unsig = match($0, /unsigned/)

char = match($0, /char/)
integ = match($0, /int/)
short = match($0, /short/)
flt = match($0, /float/)

array = match($0, /\[[0-9]*\]/)
if (array) {
    after = substr($0, RSTART + RLENGTH)
    arraydouble = match(after, /\[[0-9]*\]/)
    if (arraydouble)
        print "multidim"
}


# Custom data types
arincpos = match($0, /ARINC_Position/) 



# set spec to none, so we can test if it was assigned
spec = ""


# Get conversion specifier
if (arincpos) {
join = post pre
spec = sprintf("%s%s%s%s%s%s%s%s", pre, "Lat_Letter", join, "Latitude", join, "Lon_Letter", join "Longitude", post)
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

