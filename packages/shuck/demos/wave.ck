@import "../src/tree.ck"

// ------------------------------------------
// Example
// ------------------------------------------

[50, 51, 55, 58, 62, 67, 65, 63, 62, 65, 58, 62, 55, 58, 55, 51] @=> int pattern[];
0 => int index;

Utils utils;
1.6::second => dur wholeNote;

class Pattern {
    
    Rhodey synth => JCRev rev => dac;
    synth.gain(0.1);
    rev.mix(0.5);
    Tree tree;
    tree.scales("minor > minor pentatonic > minor chord");
    tree.chord("Cmin");

    fun void playNote(StkInstrument synth, Tree tree){
        pattern[index++ % pattern.size()] => int note;
        tree.transposeNote(note) => int transposedNote;
        synth.freq(Std.mtof(transposedNote));
        synth.noteOn(0.8);
        0.1::second => now;
        synth.noteOff(0);
    }

    fun void loopPattern(StkInstrument synth, Tree tree){
        while (true){
            spork ~ playNote(synth, tree);
            0.1::second => now;
        }
    }

    fun void logChord(){
        <<<"--------------------------">>>;
        <<<"Pose: " + "{" + tree._pose.toString() + "}">>>;
        <<<"Scale: " + tree.detect()>>>;
    }

    fun void transposeAndLogChord(string pose){
        tree.add(pose);
        <<<"--------------------------">>>;
        <<<"Pose: " + "{" + tree._pose.toString() + "}">>>;
        <<<"Scale: " + tree.detect(tree.transform())>>>;  
    }

    fun void playPattern(){
    
        spork ~ loopPattern(synth, tree);
        logChord();
        2*wholeNote => now;
        transposeAndLogChord("a3");
        2*wholeNote => now;
        transposeAndLogChord("b-1");
        2*wholeNote => now;
        transposeAndLogChord("a3");
        2*wholeNote => now;
        transposeAndLogChord("b-1");
        2*wholeNote => now;
        transposeAndLogChord("a3");
        2*wholeNote => now;
        transposeAndLogChord("b-1");
        2*wholeNote => now;
        transposeAndLogChord("a3");
        2*wholeNote => now;
    }
}

class Chords {
    
    Gain g => JCRev rev => dac;
    rev.mix(0.3);
    Rhodey s1 => g;
    Rhodey s2 => g;
    Rhodey s3 => g;
    Rhodey s4 => g;
    Rhodey s5 => g;
    s1.gain(0.1);
    s2.gain(0.1);
    s3.gain(0.1);
    s4.gain(0.1);
    s5.gain(0.1);
    Tree tree;
    tree.scales("minor > minor pentatonic > minor chord");

    fun void playChordNotes(StkInstrument synths[], Tree tree){
        [48,58,63,67,75] @=> int chord[];
        [0.3::second, 0.3::second, 0.2::second] @=> dur rhythms[];
        for (0 => int i; i < chord.size(); i++){
            Std.mtof(tree.transposeNote(chord[i])) => synths[i].freq;
        }
        for (0 => int i; i < rhythms.size(); i++){
            for (0 => int j; j < synths.size(); j++){
                synths[j].noteOn(0.8);
            }
            rhythms[i] => now;
        }
    }

    fun void loopChords(StkInstrument synths[], Tree tree){
        while (true){
            spork ~ playChordNotes(synths, tree);
            0.8::second => now;
        }
    }

    fun void playChords(){
        spork ~ loopChords([s1,s2,s3,s4,s5], tree);
        2*wholeNote => now;
        tree.add("a3 + c-2");
        2*wholeNote => now;
        tree.add("b-1");
        2*wholeNote => now;
        tree.add("a4");
        1.5*wholeNote => now;
        tree.add("a1");
        0.5*wholeNote => now;
        tree.add("a-2 + b-1 + c-2");
        2*wholeNote => now;
        tree.add("a4");
        1.5*wholeNote => now;
        tree.add("a1");
        0.5*wholeNote => now;
        tree.add("a-2 + b-1");
        2*wholeNote => now;
        tree.add("a4");
        1.5*wholeNote => now;
        tree.add("a1");
        0.5*wholeNote => now;
    }
}

Pattern piano;
Chords chords;
spork ~ piano.playPattern();
spork ~ chords.playChords();
32*wholeNote => now;