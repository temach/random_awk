# Modify databse_write and database_create_table functions
#

BEGIN {
    print "Starting"
}



# replace line (hence the next keyword)
# in create function
/int rc\;/ {
printf( "    char *errmsg = NULL;\n");
next
}

# append line to write function
/char buffer\[/ {
printf( "    char *errmsg = NULL;\n");
}



#==============================================================================================
# modify database create function
/rc = sqlite3_exec/,/Write_Log\(/ {

newline = "\
    if (sqlite3_exec(db, Create_String, NULL, NULL, &errmsg ))\n\
    {\n\
        PrintLog(WARN, \"ERROR_TEXT\", errmsg);\n\
        sqlite3_free(errmsg);"
            


re = "Log...[A-Z'a-z_0-9 ]*"
yes = match( $0, re )
if (yes) {

#get err message
errstr = substr($0, RSTART + 4, RLENGTH);

#remove crap
gsub(/\"/, "", errstr);
gsub(/\)/, "", errstr);
gsub(/\;/, "", errstr);
gsub(/\\n/, "", errstr);

# add string print specifier
errstr = errstr " table, %s"

# put err message into what to write
gsub(/ERROR_TEXT/, errstr, newline);

print newline
}
    # don't print a copy of each line
    next
} 


#========================================================================================
# modify database write function
/if \(sqlite3_exec\(db, buffer, NULL, NULL, NULL \)\)/,/Write_Log\(\"/ {

newline = "\
    // substitute ' ' (space) for character fields that are '\\0' by default\n\
    replace_chars(buffer, '\\0', ' ', 512, ';');\n\
\n\
    if (sqlite3_exec(db, buffer, NULL, NULL, &errmsg ))\n\
    {\n\
        PrintLog(WARN, \"ERROR_TEXT\", errmsg);\n\
        sqlite3_free(errmsg);"


re = "Log...[A-Z'a-z_0-9 ]*"
yes = match( $0, re )
if (yes) {

#get err message
errstr = substr($0, RSTART + 4, RLENGTH);

#remove crap
gsub(/\"/, "", errstr);
gsub(/\)/, "", errstr);
gsub(/\;/, "", errstr);
gsub(/\\n/, "", errstr);

# add string print specifier
errstr = errstr " %s"

# put err message into what to write
gsub(/ERROR_TEXT/, errstr, newline);

print newline
}
    # don't print a copy of each line
    next
} 
#==============================================================================================


# print other unaffected lines
// { print $0 }


END {
    print "Finishing"
}

