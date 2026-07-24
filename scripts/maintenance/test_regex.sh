CLUSTER="blaze-b9-thisisblaze-dev-mini-cluster"
if [[ "$CLUSTER" =~ ^([^-]+)-([^-]+)-([^-]+)-(.+)-cluster$ ]]; then
    echo "Matched 1: ${BASH_REMATCH[1]}, ${BASH_REMATCH[2]}, ${BASH_REMATCH[3]}, ${BASH_REMATCH[4]}"
elif [[ "$CLUSTER" =~ ^([^-]+)-([^-]+)-(.+)-cluster$ ]]; then
    echo "Matched 2"
else
    echo "Matched nothing"
fi
