Get updated patch set for mt7925, assuming this is ran in the directory of the repo
```sh
commit_hash=$(git rev-parse HEAD);
for patch in kernels/6.18/00[0-9][0-9]-*.patch; do
    echo "{";
    echo "  name = \"$(basename "$patch")\";";
    echo "  patch = pkgs.fetchurl {";
    echo "    url = \"https://raw.githubusercontent.com/zbowling/mt7925/$commit_hash/$patch\";";
    echo "    sha256 = \"$(node -e "
        const hash = require('crypto').createHash('sha256');
        hash.update(require('fs').readFileSync('$patch'));
        console.log('sha256-'+hash.digest('base64'));
    ")\";";
    echo "  };"; 
    echo "}";
done
```
