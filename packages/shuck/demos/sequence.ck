@import "../src/tree.ck";
@import "smuck";

Utils utils;

Rhodey r => dac;
r.gain(0.3);

"F minor > F min" => string seed;
"F min" => string chord;

Tree tree(seed);
tree.chord(chord);

tree.queryKeys(["a","b"]);
tree.queryDirection("up");
tree.querySpread(2);
tree.queryIndex(0);
tree.queryDegree(0);

"a-2 + b1" => string bySixths;
"a4 + b-2" => string descendingFourths;
"a3 + b-1" => string ascendingFourths;
"a1" => string up;

up => string pose;

fun void playNote(int midiNote, dur duration){
    tree.transposeNote(midiNote) => int transposedNote;
    r.freq(Std.mtof(transposedNote));
    r.noteOn(0.8);
    duration => now;
}

[65, 67, 68, 72] @=> int melody[];
[60, 64, 67, 64] @=> int majorChord[];
[54, 55, 60, 64, 65, 64, 60, 55] @=> int lickNotes[];
melody @=> int pattern[];
pattern.size() => int count;

while (true){
    <<<tree.detect() + ": (" + utils.list(tree.pitches()) + ")">>>;
    repeat(2){
        for (0 => int i; i < count; i++){
            playNote(pattern[i], 0.1::second);
        }
    }
    tree.add(pose);
    tree.chord(chord);
    tree.transform(1);
}
