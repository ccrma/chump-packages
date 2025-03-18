# deploy the manifest.json to CCRMA servers

# check if jq is installed
if ! command -v jq 2>&1 >/dev/null
then
    echo "jq could not be found, please install"
    exit 1
fi


# download chump to get the scripts
if [ ! -d "chump" ] ; then
    git clone https://github.com/ccrma/chump.git
fi

(cd chump && git pull)


(cd chump && make linux)

./chump/builddir-release/scripts/generate_manifest ./ > manifest.json

VER="$(jq '.["manifest-version"]' manifest.json)"
VER_DIR="~/Library/Web/chump/manifest/v${VER}/"

ssh nshaheed@ccrma-gate.stanford.edu "mkdir -p ${VER_DIR}"
scp manifest.json "nshaheed@ccrma-gate.stanford.edu:${VER_DIR}"




