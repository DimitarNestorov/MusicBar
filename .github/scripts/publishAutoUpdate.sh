#!/bin/bash

API_URL="https://api.github.com"
REPO="dimitarnestorov/MusicBar"

TAG=$(echo "$1" | cut -d / -f 3)

AUTH_HEADER="Authorization: token $2"

LAST_COMMIT_SHA=$(curl --header "$AUTH_HEADER" $API_URL/repos/$REPO/git/refs/heads/update | python3 -c "import sys, json; print(json.load(sys.stdin)['object']['sha'])")

LAST_TREE=$(curl --header "$AUTH_HEADER" $API_URL/repos/$REPO/git/commits/$LAST_COMMIT_SHA | python3 -c "import sys, json; print(json.load(sys.stdin)['tree']['sha'])")

TREE_SHA_JSON=$(curl --header "$AUTH_HEADER" --header "Content-Type: application/json" --request POST $API_URL/repos/$REPO/git/trees --data @- << EOF
{
    "base_tree": "$LAST_TREE",
    "tree": [{
        "path": "stable.json",
        "mode": "100644",
        "type": "blob",
        "content": "{\\n
    \\"currentRelease\\": \\"$TAG\\",\\n
    \\"releases\\": [\\n
        {\\n
            \\"version\\": \\"$TAG\\",\\n
            \\"updateTo\\": {\\n
                \\"version\\": \\"$TAG\\",\\n
                \\"pub_date\\": \\"$(date -u +%FT%TZ)\\",\\n
                \\"notes\\": \\"No notes\\",\\n
                \\"name\\": \\"$TAG\\",\\n
                \\"url\\": \\"https://github.com/dimitarnestorov/MusicBar/releases/download/$TAG/MusicBar.zip\\"\\n
            }\\n
        }\\n
    ]\\n
}\\n
"
    }]
}
EOF
)

TREE_SHA=$(echo "$TREE_SHA_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['sha'])")

COMMIT_SHA=$(curl --header "$AUTH_HEADER" --header "Content-Type: application/json" --request POST --data "{\"message\":\"$TAG\",\"parents\":[\"$LAST_COMMIT_SHA\"],\"tree\":\"$TREE_SHA\"}" $API_URL/repos/$REPO/git/commits | python3 -c "import sys, json; print(json.load(sys.stdin)['sha'])")

curl --header "$AUTH_HEADER" --header "Content-Type: application/json" --request POST --data "{\"sha\":\"$COMMIT_SHA\"}" $API_URL/repos/$REPO/git/refs/heads/update
