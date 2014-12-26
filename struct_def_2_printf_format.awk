##
## This is to read struct definition and create a string to 
## print the structure 
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
arrayf = "\\\"%s\\\", "

lc = 0

finalout = ""

}


// {

# Find what we got
unsig = match($0, /unsigned/)
array = match($0, /\[.?.?.?\]/)
char = match($0, /char/)
integ = match($0, /int/)
short = match($0, /short/)
flt = match($0, /float/)

arincpos = match($0, /ARINC_Position/) 

# Get conversion specifier
if (array)
spec = arrayf

else if (unsig && (char || integ || short))
spec = uintf

else if (char)
spec = charf

else if (integ || short)
spec = intf

else if (flt)
spec = fltf

else if (arincpos) {
spec = sprintf("%s%s%s%s", charf, fltf, charf, fltf)
lc += 3
}

else 
spec = sprintf("==%s==", $0)


# sub(/ .*/, "", $0)
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

