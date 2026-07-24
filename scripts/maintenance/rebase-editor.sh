#!/bin/bash
FILE=$1

# We will just write a new sequence.
# Let's first dump the sequence so we see it.
cp "$FILE" /tmp/git-rebase-todo.orig

# Replace 'pick' with 'drop' for the chore commits
sed -i -E 's/^pick ([a-f0-9]+) chore: end-of-day governance sync/drop \1 chore: end-of-day governance sync/g' "$FILE"

# For the Cloudflare token churn, let's fixup them into the fa4c56b or 536981f.
# Actually, the easiest way to deal with c3bfb66, b2c9238, 9c97257 is to just squash them together and reword.
sed -i -E 's/^pick (c3bfb66)/squash \1/g' "$FILE"
sed -i -E 's/^pick (b2c9238)/squash \1/g' "$FILE"
sed -i -E 's/^pick (9c97257)/squash \1/g' "$FILE"

