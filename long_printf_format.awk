# Given a long format string a many arguments wrap them
# at 10 per line. Insert a newline between the end of 
# format string and first argument.
#


BEGIN {
    print "Starting"
}



/INSERT INTO/,/\/\// {


offset = index($0, "%") - 5
replace = sprintf("\& \"\n%-*s\"", offset, "");

regex_string = "([^,]*%[^,]+,)"
regex_stringend = ";\","
replace_stringend = sprintf("\&\n%-*s", offset - 1, "");


regex_data = "(Data->[^,]*,)"
replacedata = sprintf("\&\n%-*s", offset - 1, "");




copy = $0
numconv = gsub(/[^,]*%[^,]+,/, "", copy)

copy = $0
numdata = gsub(/Data->[^,]*/, "", copy)


if (numconv != numdata) {
print "DIFFERENT NUMBERS"
print numconv, numdata
}


# the result
newline = $0

# ON Query
i = 1
while (numconv > 10) {
    newline = gensub(regex_string, replace, i * 10, newline)
    numconv -= 10   
    i++
}

newline = gensub(regex_stringend, replace_stringend, 1, newline)


# ON Data
newline = gensub(regex_data, replacedata, 10, newline)
newline = gensub(regex_data, replacedata, 20, newline)
newline = gensub(regex_data, replacedata, 30, newline)
newline = gensub(regex_data, replacedata, 40, newline)



print newline
next

}


# print a copy of a line
// { print $0 }

END {
    print "Finishing"
}

