@import "src/tree.ck"
@import "shortcuts.ck"

// ------------------------------------------
// Welcome to SHuck!
// Structured Harmony in ChucK
// ------------------------------------------

// This library provides tools for working with structured harmony in ChucK.

// Q: What is structured harmony?
// A: A way of organizing musical notes within hierarchical trees of chords and scales.

// Q: Why use structured harmony?
// A: You are probably using it already! Most Western music is based on hierarchical
// relationships between chords and scales. For example,
// it is common to think of a C major chord nested within a C major scale,
// that itself might be nested within a chromatic scale.

// Q: Why use SHucK?
// A: SHucK makes it easy to create, manipulate, and query musical structures of notes.
// It also provides powerful tools for voice leading and chord detection.

// Q: How do I use SHucK?
// A: See the examples below!

// ------------------------------------------
// Creating a Tree
// ------------------------------------------

// Create a tree using a string or an array of scales
Tree tree("major > maj7 > maj");
// == Tree tree("C,D,E,F,G,A,B > C,E,G,B > C,E,G");
// == Tree tree([[0,2,4,5,7,9,11],[0,4,7,11],[0,4,7]]);

// Print out the pitches of each scale
tree.printPitches();
// scale a: C4, D4, E4, F4, G4, A4, B4
// scale b: C4, E4, G4, B4
// scale c: C4, E4, G4

// Print out the notes of each scale
tree.printNotes();
// t:1, t:3, t:5, t:6, t:8, t:10, t:12
// a:1, a:3, a:5, a:7
// b:1, b:2, b:3

// ------------------------------------------
// Posing a Tree
// ------------------------------------------

// Set the current pose ("a1" = move 1 step up your first scale = maj)
tree.pose("a1");

// Move one step up the second scale (maj7)
tree.pose("b1");

// Move one step up the third scale (maj)
tree.pose("c1");

// Move in multiple directions at once by summing offsets
tree.pose("a2 + b-1 + c-1");

// t and y are reserved for chromatic and octave, respectively
tree.pose("t12 + y-1");

// ------------------------------------------
// Transposing Notes
// ------------------------------------------

// Transpose notes/chords by inputting MIDI notes to bind to the tree
tree.transposeNote(60);
tree.transform([60,64,67]);

// a1 = Move all notes one step up the C major scale
tree.pose("a1");
tree.transform([60,64,67]);
// Will transpose to D minor chord (62,65,69) (D4,F4,A4)

// b1 = Move all notes one step up the C maj7 chord
tree.pose("b1");
tree.transform([60,64,67]);
// Will transpose to E minor chord (64,67,71) (E4,G4,B4)

// c1 = Move all notes one step up the C major chord
tree.pose("c1");
tree.transform([60,64,67]);
// Will transpose to C major (1st inv) (64,67,72) (E4,G4,C5)

// Efficient voice leadings happen when you add offsets from multiple scales
tree.pose("a4");
tree.add("c-2");
tree.transform([60,64,67]);
// Will transpose to G/B (59,64,71) (B3,D4,G4)

// Harmonic sequences happen when you apply many poses over time
tree.pose("a3 + c-1");
[60,64,67] @=> int coolChord[];                     // (C4, E4, G4)
tree.transform(coolChord) @=> coolChord;       // (C4, F4, A4)
tree.transform(coolChord) @=> coolChord;       // (D4, F4, B4)
tree.transform(coolChord) @=> coolChord;       // (E4, G4, B4)
tree.transform(coolChord) @=> coolChord;       // Ascending 4ths!!

// We can store a chord within the tree to accumulate transpositions
tree.chord("C maj");
tree.pose("a1");
tree.transform(1); // 1 means to update in place (0 to return a copy)
tree.printChord();

// Get the best guess for the name of the chord
<<< tree.detect() >>>;
// Will print "D min"

// ------------------------------------------
// Querying a Tree
// ------------------------------------------

// Trees can be queried for specific transpositions of a chord
tree.scales("major > maj");
tree.chord([60,64,67]);

// Specify which keys (scales) to include with the pose
// Here, we search using the first two scales
tree.queryKeys(["a", "b"]);

// Specify whether the chord should move "up", "down", or "any" direction
// By default, the direction is "any"
tree.queryDirection("any");

// Specify the maximum absolute value for each offset in the pose
// Here, we search for all poses between a-5 + b-5 and a5 + b5
tree.querySpread(5);

// Specify whether to restrict by degree (must have a certain scale step)
// Here, we are restricting to the dominant (5th) degree of the first scale
tree.queryDegree(5);

// Specify which index to choose (0 = first closest, 1 = second closest, etc.)
// Here, we are choosing the closest chord matching our parameters
tree.queryIndex(0);

// Get the closest chord using the current parameters
tree.getClosestChord() @=> int closestChord[];
tree.printClosestChord();

// Alternatively, we can get the pose that would lead to the closest chord
tree.getClosestPose() @=> int closestPose[];
tree.clear();

// // ------------------------------------------
// // Shortcuts
// // ------------------------------------------

// // A listener can be created to detect keyboard shortcuts
// Listener listener(tree);

// // A timeout can be stored to set the duration of the listener
// listener.setTimeout(1::minute);

// // Holding A-Z will target the corresponding scale
// // Note: T is reserved for chromatic and Y is reserved for octave

// // Pressing 1-9 will sum the corresponding scale degrees
// // For example, pressing A and 1 will move up one step along the first scale ("a1")

// // Holding Minus / Tilde will toggle negative offsets
// // For example, pressing A and - and 1 will move down one step along the first scale ("a-1")

// // Pressing 0 will reset the pose to zero

// // Start listening for shortcuts
// spork ~ listener.listen();

// // The listener can be manually stopped at any time
// listener.stop();
