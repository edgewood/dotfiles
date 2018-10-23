#!/usr/bin/env python

from __future__ import print_function

import re
import sys

class Category:
  def key_by_line(obj):
    return lambda obj : obj['line_num'] 

  def __init__(self, select_function, key_function=key_by_line, sort_reverse=False):
    self.selected_items = []
    self.select_function = select_function
    self.sort_key_function = key_function
    self.sort_reverse = sort_reverse

  def scan(self, line):
    # break up line into non-empty space-delimited words
    words = [part for part in re.split(r'\s+', line) if part != '']

    item_number = words.pop(0)  # item number is always guaranteed to be there

    if words:
      item = self.select_function(words)

    if item is not None:
      item['line'] = line
      item['line_num'] = item_number
      self.selected_items.append(item)
      return True
    else:
      return False
    
  def items(self):
    return sorted(self.selected_items, key=self.sort_key_function, reverse=self.sort_reverse)

rest = Category(
    select_function=lambda words : {},
  )
pri_a = Category(
    select_function=lambda words : {} if len(words) >= 1 and words[0] == '(A)' else None,
    sort_reverse=True
  )
pri_other = Category(
    select_function=lambda words :
      {} if len(words) >= 1 and re.match(r'\([B-Z]\)', words[0]) else None,
  )

scan_order = [
    pri_a, pri_other, rest
]

print_order = [
    rest, pri_other, pri_a
]

#for line in sys.stdin:
for line in open("tmp/todo.txt"):
  for category in scan_order:
    was_consumed = category.scan(line)

    if was_consumed:
      break

  if not was_consumed:
    raise Exception("Line was not consumed: '{}'...".format(line[:15]))

for category in print_order:
  for item in category.items():
    print(item['line'], end="")


