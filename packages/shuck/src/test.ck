@import "regex.ck"
@import "tree.ck"

Utils utils;
Regex regex;

fun void line(){
    <<< "-------------------" >>>;
}

fun void header(string title){
    line();
    <<< title >>>;
    line();
}

0 => int testCount;
fun void test() {header("Test " + ++testCount + ":"); }
fun void error(){ <<< "Error!" >>>; }
fun void pass(){ <<< "Pass!" >>>; }

fun void main(){
    Tree tree("major > maj7 > maj");

    header("Pitches");
    tree.printPitches();

    header("Notes");
    tree.printNotes();

    test();
    tree.chord("C major");
    <<< "Input: " + utils.list(tree.chord()) >>>;
    tree.pose("a1");
    <<< "Pose:  " + tree.pose().toString() >>>;
    tree.transform(1);
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), regex.inputScale("D dorian"))){ pass(); } 
    else { return error(); }

    test();
    tree.chord("C maj7");
    <<< "Input: " + utils.list(tree.chord()) >>>;
    tree.pose("b1");
    <<< "Pose:  " + tree.pose().toString() >>>;
    tree.transform(1);
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), regex.inputScale("E minb6"))){ pass(); } 
    else { return error(); }

    test();
    tree.chord("C maj");
    <<< "Input: " + utils.list(tree.chord()) >>>;
    tree.pose("c1");
    <<< "Pose:  " + tree.pose().toString() >>>;
    tree.transform(1);
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), regex.inputScale("C maj6/3"))){ pass(); } 
    else { return error(); }

    test();
    tree.chord([66, 67, 68, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    tree.pose("a1");
    <<< "Pose:  " + tree.pose().toString() >>>;
    tree.transform(1);
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [68, 69, 70, 69])){ pass(); } 
    else { return error(); }

    test();
    tree.chord([66, 67, 68, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    tree.pose("b1");
    <<< "Pose:  " + tree.pose().toString() >>>;
    tree.transform(1);
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [70, 71, 72, 71])){ pass(); } 
    else { return error(); }

    test();
    tree.chord([66, 67, 68, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    tree.pose("c1");
    <<< "Pose:  " + tree.pose().toString() >>>;
    tree.transform(1);
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [71, 72, 73, 72])){ pass(); } 
    else { return error(); }

    test();
    tree.chord([60, 64, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    <<< "VL: Closest Chord Up" >>>;
    tree.queryKeys(["a","c"]);
    tree.queryDirection("up");
    tree.chord(tree.getClosestChord());
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [60, 64, 69])){ pass(); } 
    else { return error(); }
    if (tree.detect() == "A min (r1)"){ pass(); } 
    else { return error(); }

    test();
    tree.chord([60, 64, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    <<< "VL: Closest Chord Down" >>>;
    tree.queryKeys(["a","c"]);
    tree.queryDirection("down");
    tree.chord(tree.getClosestChord());
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [59, 64, 67])){ pass(); } 
    else { return error(); }
    if (tree.detect() == "E min (r2)"){ pass(); } 
    else { return error(); }

    test();
    tree.chord([60, 64, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    <<< "VL: Closest Dominant Chord" >>>;
    tree.queryKeys(["a","c"]);
    tree.queryDirection("any");
    tree.queryDegree(5);
    tree.chord(tree.getClosestChord());
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [59, 62, 67])){ pass(); } 
    else { return error(); }
    if (tree.detect() == "G maj (r1)" || tree.detect() == "G maj6/3"){ pass(); } 
    else { return error(); }

    test();
    tree.chord([60, 64, 67]);
    <<< "Input: " + utils.list(tree.chord()) >>>;
    <<< "VL: Closest Subdominant Chord" >>>;
    tree.queryKeys(["a","c"]);
    tree.queryDirection("any");
    tree.queryDegree(4);
    tree.chord(tree.getClosestChord());
    <<< "Output:" + utils.list(tree.chord()) >>>;
    if (utils.compare(tree.chord(), [60, 65, 69])){ pass(); } 
    else { return error(); }
    if (tree.detect() == "F maj (r2)" || tree.detect() == "F maj6/4"){ pass(); } 
    else { return error(); }

    header("All tests passed!");
}

main();