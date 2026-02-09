public class Utils {

    // ----------------------------------------
    // String
    // ----------------------------------------
    
    fun string list(string array[], string separator){
        "" => string result;
        array.size() => int size;
        if (size == 0) return "";
        for (0 => int i; i < size; i++){
            array[i] +=> result;
            separator +=> result;
        }
        return result.substring(0, result.length() - separator.length());
    }
    fun string list(string array[]) { return list(array, ","); }

    fun string list(int array[], string separator){
        "" => string result;
        array.size() => int size;
        if (size == 0) return "";
        for (0 => int i; i < size; i++){
            array[i] +=> result;
            separator +=> result;
        }
        return result.substring(0, result.length() - separator.length());
    }
    fun string list(int array[]) { return list(array, ","); }

    fun void print(string array[], string separator){
        <<< list(array, separator) >>>;
    }
    fun void print(string array[]) { print(array, ","); }
    fun void print(int array[], string separator){
        <<< list(array, separator) >>>;
    }
    fun void print(int array[]) { print(array, ","); }

    fun int compare(int arr1[], int arr2[]){
        arr1.size() => int size1;
        arr2.size() => int size2;
        if (size1 != size2) return 0;
        for (0 => int i; i < size1; i++){
            if (arr1[i] != arr2[i]) return false;
        }
        return true;
    }

    // Split a string by a token
    fun string[] split(string str, string token){
        str.length() => int strLength;
        token.length() => int tokenLength;
        if (strLength == 0) return [""];
        if (tokenLength == 0) return [str];

        string result[0];
        "" => string current;
        for (0 => int i; i < strLength; i++){
            if (i + tokenLength <= strLength && str.substring(i, tokenLength) == token){
                current => string match;
                result << match;
                "" => current;
                tokenLength - 1 +=> i;
            } else {
                "" => string s;
                s.appendChar(str.charAt(i)) => string c;
                c +=> current;
            }
        }
        result << current;
        return result;
    }

    // ----------------------------------------
    // Numbers
    // ----------------------------------------

    // Custom mod to handle negative numbers
    fun int mod(int a, int b){
        return ((a % b) + b) % b;
    }

    // Custom floor to handle negative numbers
    fun int bottomFloor(int a, int b){
       (a $ float) / b => float value;
        return Math.floor(value) $ int;
    }

    // Convert a number to a letter (0 => "a", etc., skipping past 't' and 'y')
    fun string numToLetter(int n, int absolute){
        n % 26 => int letterIndex;
        if (!absolute){
            if (letterIndex >= 19) letterIndex++; // Skip 't'
            if (letterIndex >= 24) letterIndex++; // Skip 'y'
        }
        "" => string result;
        result.appendChar(97 + letterIndex);
        return result;
    }
    fun string numToLetter(int n){
        return numToLetter(n, 0);
    }

    // Convert a letter to a number
    fun int letterToNum(string letter){
        if (!letter.length()) return -1;
        letter.charAt(0) - 97 => int letterIndex;
        if (letterIndex > 19) letterIndex--; // Skip 't'
        if (letterIndex > 24) letterIndex--; // Skip 'y'
        return letterIndex;
    }

    // Convert a pitch class to a number ("C" => 0, "C#" => 1, etc.)
    fun int pitchClassToNumber(string pc){
        pitchClassMap.size() => int size;
        for (0 => int i; i < size; i++){
            pitchClassMap[i] @=> string pcs[];
            for (0 => int j; j < pcs.size(); j++){
                if (pcs[j] == pc) return i;
            }
        }
        return -1;
    }

    fun int[] subarray(int array[], int start, int end){
        array.size() => int size;
        int result[0];
        if (start > end) return result;
        for (start => int i; i < end; i++){
            result << array[i];
        }
        return result;
    }
    fun int[] subarray(int array[], int start){
        array.size() => int size;
        return subarray(array, start, size);
    }

    fun int[] mergeSort(int indices[], int values[]) {
        if (indices.size() <= 1) return indices;

        // split
        indices.size() / 2 => int mid;
        subarray(indices, 0, mid) @=> int left[];
        subarray(indices, mid) @=> int right[];

        mergeSort(left, values) @=> left;
        mergeSort(right, values) @=> right;

        // merge
        int i, j;
        int merged[0];
        while (i < left.size() && j < right.size()) {
            if (values[left[i]] <= values[right[j]]){
                merged << left[i++];
            } else {
                merged << right[j++];
            }
        }
        while (i < left.size()) {
            merged << left[i++];
        }
        while (j < right.size()) {
            merged << right[j++];
        }

        return merged;
    }

    // ----------------------------------------
    // Notes
    // ----------------------------------------

    // Base chromatic notes
    [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71] @=> int chromaticNotes[];

    // Create chromatic notes from a range
    fun int[] createChromaticNotes(int low){
        int result[0];
        for (low => int i; i < low + 12; i++){
            result << i;
        }
        return result;
    }

    // Pitch map with enharmonic equivalents
    string pitchClassMap[12][0];
    ["B#", "C", "Cbb"] @=> pitchClassMap[0];
    ["B##", "C#", "Db"] @=> pitchClassMap[1];
    ["C##", "D", "Dbb"] @=> pitchClassMap[2];
    ["D#", "Eb", "Fbb"] @=> pitchClassMap[3];
    ["D##", "E", "Fb"] @=> pitchClassMap[4];
    ["E#", "F", "Gbb"] @=> pitchClassMap[5];
    ["E##", "F#", "Gb"] @=> pitchClassMap[6];
    ["F##", "G", "Abb"] @=> pitchClassMap[7];
    ["G#", "Ab"] @=> pitchClassMap[8];
    ["G##", "A", "Bbb"] @=> pitchClassMap[9];
    ["A#", "Bb", "Cbb"] @=> pitchClassMap[10];
    ["A##", "B", "Cb"] @=> pitchClassMap[11];

    // Get the pitch class of a midi note (60 = C4 = "C")
    fun string getPitchClass(int note){
        mod(note, 12) => int pc;
        pitchClassMap.size() => int size;
        for (0 => int i; i < size; i++){
            if (i == pc) return pitchClassMap[i][1];
        }
        return "?";
    }

    // Get the octave number of a note (60 = C4 = 4)
    fun int getOctave(int note){
        return bottomFloor(note - 12, 12);
    }

    // Get the pitch of a note
    fun string getPitch(int note){
        return getPitchClass(note) + getOctave(note);
    }

    // Get the number of octaves between two notes
    fun int getOctaveDistance(int note1, int note2){
        return getOctave(note2) - getOctave(note1);
    }

    // Get the degree of a note in a midi scale
    fun int getDegree(int note, int scale[]){
        scale.size() => int size;
        note % 12 => int base;
        for (0 => int i; i < size; i++){
            if (scale[i] % 12 == base) return i;
        }
        return -1;
    }

    // ----------------------------------------
    // Scale
    // ----------------------------------------
    int scaleMap[0][0];

    // Basics
    [0,1,2,3,4,5,6,7,8,9,10,11] @=> scaleMap["chromatic"];
    [0,2,4,5,7,9,11] @=> scaleMap["major"];
    [0,2,4,5,7,9,11] @=> scaleMap["major scale"];
    [0,2,3,5,7,8,10] @=> scaleMap["minor"];
    [0,2,3,5,7,8,10] @=> scaleMap["minor scale"];
    [0,2,3,5,7,9,11] @=> scaleMap["melodic"];

    // Harmonic Minor Modes
    [0,2,3,5,7,8,11] @=> scaleMap["harmonic minor"];
    [0,1,3,5,6,9,10] @=> scaleMap["locrian #6"];
    [0,2,4,5,8,9,11] @=> scaleMap["ionian #5"];
    [0,2,3,6,7,9,10] @=> scaleMap["dorian #4"];
    [0,1,4,5,7,8,10] @=> scaleMap["phrygian dominant"];
    [0,3,4,6,7,9,11] @=> scaleMap["lydian #2"];
    [0,1,3,4,6,8,9] @=> scaleMap["ultra locrian"];

    // Harmonic Major Modes
    [0,2,4,5,7,8,11] @=> scaleMap["harmonic major"];
    [0,2,3,5,6,9,10] @=> scaleMap["dorian b5"];
    [0,1,3,4,7,8,10] @=> scaleMap["phrygian b4"];
    [0,2,3,6,7,9,11] @=> scaleMap["lydian b3"];
    [0,1,4,5,7,9,10] @=> scaleMap["mixolydian b2"];
    [0,3,4,6,8,9,11] @=> scaleMap["lydian augmented #2"];
    [0,1,3,5,6,8,9] @=> scaleMap["locrian bb7"];

    // Double Harmonic Modes
    [0,1,4,5,7,8,11] @=> scaleMap["double harmonic"];
    [0,3,4,6,7,10,11] @=> scaleMap["lydian #2 #6"];
    [0,1,3,4,7,8,9] @=> scaleMap["ultra locrian #5"];
    [0,2,3,6,7,8,11] @=> scaleMap["double harmonic minor"];
    [0,1,4,5,6,9,10] @=> scaleMap["mixolydian b5 b2"];
    [0,3,4,5,8,9,11] @=> scaleMap["ionian #5 #2"];
    [0,1,2,5,6,8,9] @=> scaleMap["locrian bb3 bb7"];

    // Melodic Minor Modes
    [0,2,3,5,7,9,11] @=> scaleMap["melodic minor"];
    [0,1,3,5,7,9,10] @=> scaleMap["dorian b2"];
    [0,2,4,6,8,9,11] @=> scaleMap["lydian augmented"];
    [0,2,4,6,7,9,10] @=> scaleMap["acoustic"];
    [0,2,4,5,7,8,10] @=> scaleMap["aeolian dominant"];
    [0,2,3,5,6,8,10] @=> scaleMap["half diminished"];
    [0,1,3,4,6,8,10] @=> scaleMap["super locrian"];

    // Neapolitan Major Modes
    [0,1,3,5,7,9,11] @=> scaleMap["neapolitan major"];
    [0,2,4,6,8,10,11] @=> scaleMap["leading whole tone"];
    [0,2,4,6,8,9,10] @=> scaleMap["lydian augmented dominant"];
    [0,2,4,6,7,8,10] @=> scaleMap["lydian minor"];
    [0,2,4,5,6,8,10] @=> scaleMap["major locrian"];
    [0,2,3,4,6,8,10] @=> scaleMap["super locrian #2"];
    [0,1,2,4,6,8,10] @=> scaleMap["super locrian bb3"];

    // Neapolitan Minor Modes
    [0,1,3,5,7,8,11] @=> scaleMap["neapolitan minor"];
    [0,2,4,6,7,10,11] @=> scaleMap["lydian #6"];
    [0,2,4,5,8,9,10] @=> scaleMap["mixolydian augmented"];
    [0,2,3,6,7,8,10] @=> scaleMap["aeolian #4"];
    [0,1,4,5,6,8,10] @=> scaleMap["locrian dominant"];
    [0,3,4,5,7,9,11] @=> scaleMap["ionian #2"];
    [0,1,2,4,6,8,9] @=> scaleMap["ultra locrian bb3"];

    // Modes
    [0,2,4,6,7,9,11] @=> scaleMap["lydian"];
    [0,2,4,5,7,9,11] @=> scaleMap["ionian"];
    [0,2,4,5,7,9,10] @=> scaleMap["mixolydian"];
    [0,2,3,5,7,9,10] @=> scaleMap["dorian"];
    [0,2,3,5,7,8,10] @=> scaleMap["aeolian"];
    [0,1,3,5,7,8,10] @=> scaleMap["phrygian"];
    [0,1,3,5,6,8,10] @=> scaleMap["locrian"];

    // Pentatonic
    [0,2,4,7,9] @=> scaleMap["pentatonic"];
    [0,2,4,7,9] @=> scaleMap["major pentatonic"];
    [0,3,5,7,10] @=> scaleMap["minor pentatonic"];
    [0,4,5,7,10] @=> scaleMap["mixolydian pentatonic"];
    [0,4,5,7,11] @=> scaleMap["ryukyu"];
    [0,1,5,7,8] @=> scaleMap["in"];
    [0,2,5,7,8] @=> scaleMap["yo"];
    [0,1,5,7,10] @=> scaleMap["insen"];
    [0,2,3,7,8] @=> scaleMap["hirajoshi"];
    [0,1,5,6,10] @=> scaleMap["iwato"];

    // Hexatonic
    [0,3,5,6,7,10] @=> scaleMap["blues"];
    [0,3,4,7,8,11] @=> scaleMap["augmented"];
    [0,2,4,6,9,10] @=> scaleMap["prometheus"];
    [0,1,4,6,7,10] @=> scaleMap["tritone"];
    [0,1,3,5,8,10] @=> scaleMap["ritsu"];
    [0,2,4,6,8,10] @=> scaleMap["whole tone"];
    [0,2,4,6,8,10] @=> scaleMap["wt"];

    // Octatonic
    [0,2,4,5,7,8,9,11] @=> scaleMap["bebop major"];
    [0,2,3,4,5,7,9,10] @=> scaleMap["bebop minor"];
    [0,2,3,5,7,8,10,11] @=> scaleMap["bebop harmonic minor"];
    [0,2,3,5,7,8,9,11] @=> scaleMap["bebop melodic minor"];
    [0,2,4,5,7,9,10,11] @=> scaleMap["bebop dominant"];
    [0,2,3,5,6,8,9,11] @=> scaleMap["whole-half"];
    [0,1,3,4,6,7,9,10] @=> scaleMap["half-whole"];

    // Sixth chords
    [0,4,7,9] @=> scaleMap["6"];
    [0,3,7,9] @=> scaleMap["min6"];
    [0,3,7,8] @=> scaleMap["minb6"];

    // Triads
    [0,4,7] @=> scaleMap["major chord"];
    [0,4,7] @=> scaleMap["maj"];
    [0,3,7] @=> scaleMap["minor chord"];
    [0,3,7] @=> scaleMap["min"];
    [0,3,6] @=> scaleMap["dim"];
    [0,4,8] @=> scaleMap["aug"];
    [0,3,6] @=> scaleMap["dim"];
    [0,3,9] @=> scaleMap["dim6"];
    [0,6,9] @=> scaleMap["dim6/4"];
    [0,2,7] @=> scaleMap["sus2"];
    [0,5,7] @=> scaleMap["sus4"];
    [4, 7, 12] @=> scaleMap["maj6/3"];
    [7, 12, 16] @=> scaleMap["maj6/4"];
    [0,1,6] @=> scaleMap["viennese trichord"];
    [0,6,7] @=> scaleMap["viennese trichord"];

    // Sevenths
    [0,4,7,10] @=> scaleMap["7"];
    [0,4,7,11] @=> scaleMap["maj7"];
    [0,3,7,10] @=> scaleMap["min7"];
    [0,3,6,10] @=> scaleMap["m7b5"];
    [0,3,6,9] @=> scaleMap["dim7"];


    string scaleNames[0];
    scaleMap.getKeys(scaleNames);
    scaleNames.size() => int scaleMapSize;

    // Sum the notes of a scale with an offset
    fun int[] sumScale(int scale[], int offset){
        scale.size() => int size;
        int result[size];
        for (0 => int i; i < size; i++){
            scale[i] + offset => result[i];
        }
        return result;
    }

    // Sort midi notes in ascending order
    fun int[] sortScale(int notes[]){
        int result[0];
        notes.size() => int size;
        for (0 => int i; i < size; i++){
            notes[i] => int note;
            i > 0 ? notes[i - 1] : -1 => int prev;
            if (i > 0 && note <= prev){
                note => int newNote;
                while (newNote <= prev){
                    12 +=> newNote;
                }
                result << newNote;
            } else {
                result << note;
            }
        }
        return result;
    }

    // Print out a midi scale
    fun void printScale(int scale[]){
        "" => string result;
        for (0 => int i; i < scale.size(); i++){
            getPitchClass(scale[i]) + getOctave(scale[i]) => string note;
            note +=> result;
            if (i < scale.size() - 1) ", " +=> result;
        }
        <<< result >>>;
    }

    // Print out a list of midi scales
    fun void printScales(int scales[][]){
        "" => string result;
        for (0 => int i; i < scales.size(); i++){
            printScale(scales[i]);
            if (i < scales.size() - 1) " | " +=> result;
        }
    }

    // ----------------------------------------
    // Chords
    // ----------------------------------------

    // Get the distance between two chords
    fun int getChordDistance(int chord1[], int chord2[]){
        0 => int total;
        chord1.size() => int length1;
        chord2.size() => int length2;
        if (length1 != length2) return -1;
        for (0 => int i; i < length1; i++){
            Math.abs(chord2[i] - chord1[i]) +=> total;
        }
        return total;
    }

    // Get the error between two chords
    fun int getChordError(int chord1[], int chord2[]){
        0 => int total;
        chord1.size() => int length1;
        chord2.size() => int length2;
        if (length1 != length2) return -1;
        for (0 => int i; i < length1; i++){
            chord2[i] - chord1[i] +=> total;
        }
        return total;
    }

    // ----------------------------------------
    // Vectors
    // ----------------------------------------

    // Sum together two vectors
    fun int[] sumVectors(int a[], int b[]){
        int result[0];
        string keys1[0];
        string keys2[0];
        a.getKeys(keys1);
        b.getKeys(keys2);
        for (string key : keys1) { a[key] => result[key]; }
        for (string key : keys2) { b[key] +=> result[key]; }
        return result;
    }

    // Omit the chromatic values of a vector
    fun int[] getScala(int vec[]){
        int result[0];
        string keys[0];
        vec.getKeys(keys);
        for (string key : keys) { 
            if (key == "t") continue;
            if (key == "y") continue;
            vec[key] => result[key];
        }
        return result;
    }

    // Get the chromatic values of a vector
    fun int getChroma(int vec[]){
        0 => int result;
        if (vec.isInMap("t")) vec["t"] +=> result;
        if (vec.isInMap("y")) vec["y"] * 12 +=> result;
        return result;
    }
}

Utils utils;
utils.test() => int testResult;
if (!testResult){ <<< "Utils failed!" >>>; }