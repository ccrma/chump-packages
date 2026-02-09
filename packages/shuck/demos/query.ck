@import "tree.ck";

Utils utils;
Rhodey r => dac;
"minor > min7" => string seed;
"min7" => string chord;
Tree tree(seed);
tree.chord(chord);
tree.queryKeys(["a","b"]);
tree.queryDirection("up");
tree.querySpread(2);
tree.queryIndex(0);
tree.queryDegree(0);

string poses[0];
int total[0];

for (0 => int i; i < 16; i++){
    tree.transform(chord, total, 1);
    tree.getClosestPose() @=> int vector[];
    utils.sumVectors(vector, total) @=> total;
    Pose pose(vector);
    pose.toString() => string poseStr;
    poses << poseStr;
    <<<"Computed pose: " + poseStr + "">>>;
    <<<100/16*i + "% complete">>>;
}

tree.chord(chord);
tree.clear();

for (0 => int i; i < poses.size(); i++){
    <<<tree.detect() + ": (" + utils.list(tree.pitches()) + ")">>>;
    repeat(2){
        for (0 => int j; j < tree.chord().size(); j++){
            r.freq(Std.mtof(tree.chord()[j]));
            r.noteOn(0.8);
            0.1::second => now;
        }
    }
    tree.chord(chord);
    tree.pose(poses[i]);
    tree.transform(1);
}
