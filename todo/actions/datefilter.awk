
# This script relies on the fact that a lexical sort of YYYY-MM-DD datestrings
# produces the same result as a calendar sort, but avoids the tricky calendar
# math.  It will *not* work for other types of datestring.

BEGIN {
  # save today's date in a t:YYYY-MM-DD datestring
  today = strftime("t:%Y-%m-%d")
}
{
  # should this line be printed? default yes
  doPrint = 1

  # iterate over each "field" (space-delimited words)
  for(i = 1; i <= NF && doPrint; i++) {
    # does this field match a t:YYYY-MM-DD datestring?
    m = match($i, "t:[0-9]{4}-(0?[0-9]|1[0-2])-([0-2]?[0-9]|3[01])");

    # if so, and the datestring is lexically after today's datestring, don't print
    if(m > 0 && $i > today) {
      doPrint = 0
    }
  }

  if(doPrint) {
    print $0
  }
}
