# print "done" items unconditionally without checking projects
$2 ~ /^x$/ {
  print $0
  next
}
# check projects for all other items
$2 !~ /^x$/ { 
  # if the line has a project on it
  if(match($0, /\+([[:alnum:]]+)/, arr) && arr[0]) {

    # if this project hasn't been seen
    if(!projects[arr[0]]) {
      # print the line, then mark that we've seen this project
      print $0;
      projects[arr[0]] = 1;
    }
  }
  # print non-project lines unconditionally
  else {
    print $0
  }
}
