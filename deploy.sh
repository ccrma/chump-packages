# deploy the manifest.json to CCRMA servers

# download chump to get the scripts
if [ ! -d "chump" ] ; then
    git clone https://github.com/ccrma/chump.git
fi

(cd chump && git pull)


(cd chump && make linux)

./chump/builddir-release/scripts/generate_manifest ./ > manifest.json

scp manifest.json nshaheed@ccrma-gate.stanford.edu:~/Library/Web/chump 




