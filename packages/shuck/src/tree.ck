@import "utils.ck"
@import "regex.ck"
@import "scale.ck"
@import "note.ck"
@import "pose.ck"
@import "query.ck"

public class Tree {
    Regex regex;
    Utils utils;
    Scale _scales[0];
    Pose _pose;
    Query _query;
    int _chord[0];

    fun Scale scale(int index){ 
        return this._scales[index - 1]; 
    }
    fun Scale[] scales(){ return this._scales; }
    fun Scale[] scales(int scales[][]){ this(scales); return this._scales; }
    fun Scale[] scales(string scales){ this(regex.inputScales(scales)); return this._scales; }
    
    fun Pose pose(){ return this._pose; }
    fun Pose pose(int offset[]){ new Pose(offset) @=> this._pose; return this._pose; }
    fun Pose pose(string offset){ pose(regex.inputVector(offset)); return this._pose; }
    fun void add(int offset[]){
        utils.sumVectors(_pose.offset, offset) @=> int newOffset[];
        pose(newOffset);
    }
    fun void add(string offset){ add(regex.inputVector(offset)); }
    fun void clear(){ new Pose() @=> this._pose; }
    fun string[] pitches(){
        chord().size() => int size;
        string pitches[0];
        for (0 => int i; i < size; i++){
            pitches << utils.getPitch(chord()[i]);
        }
        return pitches;
    }
    fun int[] chord(){ return _chord; }
    fun int[] chord(int chord[]){ chord @=> this._chord; return this._chord; }
    fun int[] chord(string chord){ regex.inputScale(chord) @=> this._chord; return this._chord; }

    // Convert midi to nested scales
    fun @construct(int scales[][]){
        scales.size() => int count;
        Scale chain[0];
        for (0 => int i; i < count; i++){

            // Get the current scale
            scales[i] @=> int scale[];
            scale.size() => int length;

            // Get the parent or chromatic scale
            utils.chromaticNotes @=> int parent[];
            if (i > 0) scales[i-1] @=> parent;

            // Iterate over each note
            Note newNotes[0];
            for (0 => int j; j < length; j++){
                scale[j] => int note;

                // Look for a match in the parent
                utils.getDegree(note, parent) => int degree;
                if (degree < 0) continue;

                // Get the octave distance
                utils.getOctaveDistance(parent[degree], note) => int octave;
                int offset[0];
                octave => offset["y"];

                // Add a scale id
                utils.numToLetter(i) => string id;

                // Add the new scale note
                newNotes << new Note(id, degree, offset);
            }

            // Add the scale to the chain
            utils.numToLetter(i) => string id;
            chain << new Scale(id, newNotes);
        }
        chain @=> this._scales;
    }

    fun @construct(int scales[][], int offset[]){
        this.scales(scales);
        this.pose(offset);
    }

    fun @construct(string scales){
        this(regex.inputScales(scales));
    }

    fun @construct(string scales, string offset){
        this(regex.inputScales(scales), regex.inputVector(offset));
    }

    // Get a chain of scales starting from an id
    fun Scale[] getChain(string id){
        Scale chain[0];
        for (Scale scale : _scales){
            if (id >= scale.id){ chain << scale; }
        }
        return chain;
    }

    // Chain and unpack a scale note to MIDI
    fun int resolveNote(Note note, Scale chain[]){
        chain.size() => int count;
        Note chainedNote(note.id, note.degree, note.offset);
        for (count-1 => int i; i >= 0; i--){
            chain[i].transposeNote(chainedNote) @=> chainedNote;
        }
        return chainedNote.unpack();
    }

    // Chain and unpack a set of scales to a MIDI scale
    fun int[] resolveToScale(Scale scales[]){
        scales.size() => int count;
        int defaultScale[0];
        if (count == 0) return defaultScale;
        if (count == 1) return scales[0].unpack();

        // Get the last scale in the chain
        scales @=> Scale currentScales[];
        currentScales[count-1] @=> Scale currentScale;
        currentScales.popBack();

        // Transpose up along the scales
        while (currentScales.size() > 0){
            currentScales[currentScales.size()-1] @=> Scale parentScale;
            currentScales.popBack();
            parentScale.transposeScale(currentScale) @=> currentScale;
        }

        // Unpack the final scale
        return currentScale.unpack();
    }

    // Convert nested scales to midi by resolving them
    fun int[][] resolveScales(){
        _scales.size() => int size;
        int midiScales[0][0];
        for (0 => int i; i < size; i++){
            Scale chain[0];
            for (0 => int j; j <= i; j++){
                chain << _scales[j];
            }
            midiScales << resolveToScale(chain);
        }
        return midiScales;
    }

    // Autobind a note to a chain of scales
    fun Note bindNote(int midi){
        _scales.size() => int size;

        // Handle chromatic notes in no scale
        if (size == 0){
            midi % 12 => int degree;
            utils.getOctaveDistance(utils.chromaticNotes[0], midi) @=> int octave;
            int offset[0];
            if (octave != 0) octave => offset["y"];
            return new Note("t", degree, offset);
        }

        resolveScales() @=> int midiChain[][];
        midiChain.size() ? midiChain[midiChain.size()-1] : utils.chromaticNotes @=> int tonicScale[];
        tonicScale.size() ? tonicScale[0] : utils.chromaticNotes[0] => int tonicNote;
        utils.createChromaticNotes(tonicNote) @=> int chromaticScale[];

        for (size - 1 => int i; i >= 0; i--){
            midiChain[i] @=> int scale[];
            scale.size() => int scaleSize;
            if (scaleSize == 0) continue;
            _scales[i].id => string id;
            utils.getDegree(midi, scale) => int degree;
            // Check for an exact match with the current scale
            if (degree > -1){
                utils.getOctaveDistance(scale[degree], midi) @=> int octave;
                int offset[0];
                if (octave != 0) octave => offset["y"];
                return new Note(id, degree, offset);
            }

            // Check parent scales for neighbors, preferring deep matches
            string parentIds[0];
            int parentScales[0][0];
            for (i - 1 => int j; j >= 0; j--){
                parentIds << _scales[j].id;
                parentScales << midiChain[j];
            }
            parentIds << "t";
            i => int parentCount;
            for (0 => int j; j < parentCount + 1; j++){
                chromaticScale @=> int parentScale[];
                "t" => string parentId;
                12 => int parentSize;
                if (j < parentCount){
                    parentIds[j] => parentId;
                    parentScales[j] @=> parentScale;
                    parentScale.size() => parentSize;
                }
                utils.getDegree(midi, parentScale) => int degree;
                if (degree < 0) continue;

                // Check if the note can be lowered to fit the scale
                utils.mod(degree - 1, parentSize) => int lower;
                parentScale[lower] => int lowerMidi;
                utils.bottomFloor(degree - 1, parentSize) => int lowerWrap;
                utils.getDegree(lowerMidi, scale) => int lowerDegree;

                // If the lowered note exists in the current scale,
                // add the note as an upper neighbor
                if (lowerDegree > -1){
                    utils.getOctaveDistance(parentScale[degree], midi) + lowerWrap => int octave;
                    int offset[0];
                    if (octave != 0) octave => offset["y"];
                    1 => offset[parentId];
                    return new Note(id, lowerDegree, offset);
                }

                // Check if the note can be raised to fit the scale
                utils.mod(degree + 1, parentSize) => int upper;
                parentScale[upper] => int upperMidi;
                utils.bottomFloor(degree + 1, parentSize) => int upperWrap;
                utils.getDegree(upperMidi, scale) => int upperDegree;

                // If the raised note exists in the current scale,
                // add the note as a lower neighbor
                if (upperDegree > -1){
                    utils.getOctaveDistance(parentScale[degree], midi) + upperWrap => int octave;
                    int offset[0];
                    if (octave != 0) octave => offset["y"];
                    -1 => offset[parentId];
                    return new Note(id, upperDegree, offset);
                }
            }
        }

        // If no match has been found, set as a neighbor of the tonic
        midi - tonicNote => int dist;
        int offset[0];
        if (dist != 0) dist => offset["t"];
        return new Note(_scales[size-1].id, 0, offset);
    }

    // Transpose a MIDI note using the given scales and vector
    fun int transposeNote(Note scaleNote){

        // Part 1: Bind the MIDI note to the given scales
        scaleNote @=> Note note;

        // Part 2: Extract the transpositions from the vector
        utils.getScala(_pose.offset) @=> int scala[];
        utils.getChroma(_pose.offset) @=> int chroma;

        // Part 3: Apply scalar transpositions to the note
        getChain(note.id) @=> Scale chain[];
        utils.sumVectors(note.offset, scala) @=> int newOffset[];
        Note posedNote(note.id, note.degree, newOffset);
        resolveNote(posedNote, chain) @=> int newMidi;

        // Part 4: Apply chromatic transpositions and return
        return newMidi + chroma;
    }
    fun int transposeNote(int midi){
        return transposeNote(bindNote(midi));
    }

    // Transform the chord of a tree 
    fun int[] transform(int chord[], int update){
        chord.size() => int size;
        int newChord[size];
        for (0 => int i; i < size; i++){
            transposeNote(chord[i]) => newChord[i];
        }
        if (update) newChord @=> this._chord;
        return newChord;
    }
    fun int[] transform(int chord[], string pose, int update){
        this.pose(pose);
        return transform(chord, update);
    }
    fun int[] transform(int chord[], int pose[], int update){
        this.pose(pose);
        return transform(chord, update);
    }
    fun int[] transform(int update){ return transform(this.chord(), update); }
    fun int[] transform(int chord[]){ return transform(chord, 0); }
    fun int[] transform(string chord){
        this.chord(chord);
        return transform(this.chord(), 0);
    }
    fun int[] transform(string chord, int pose[]){
        this.chord(chord);
        this.pose(pose);
        return transform(this.chord(), 0);
    }
    fun int[] transform(int chord[], string pose){
        this.pose(pose);
        return transform(chord, 0);
    }
    fun int[] transform(string chord, string pose){
        this.chord(chord);
        this.pose(pose);
        return transform(this.chord(), 0);
    }
    fun int[] transform(string chord, int pose[], int update){
        this.chord(chord);
        this.pose(pose);
        return transform(this.chord(), update);
    }
    fun int[] transform(){ return transform(this.chord(), 0); }

    // Print the nested scale notes of a tree
    fun void printNotes(){
        for (0 => int i; i < _scales.size(); i++){
            <<< _scales[i].toString() >>>;
        }
    }

    // Print the pitches of a tree
    fun void printPitches(){
        resolveScales() @=> int midiScales[][];
        for (0 => int i; i < midiScales.size(); i++){
            midiScales[i] @=> int midiScale[];
            "" => string result;
            for (0 => int j; j < midiScale.size(); j++){
                midiScale[j] => int note;
                utils.getPitch(note) +=> result;
                "," +=> result;
            }
            if (result.length()) {
                result.substring(0, result.length() - 1) => result;
            }
            <<< result >>>;
        }
    }

    // Print the pose of a tree
    fun void printPose(){ <<< _pose.toString() >>>;}

    // Print the chord of a tree
    fun void printChord(){ utils.print(chord()); }

    // Try to detect the chord of a tree
    fun string detect(int chord[]){
        chord.size() => int size;
        string scaleNames[0];
        utils.scaleMap.getKeys(scaleNames);

        // Check for an exact transposition
        for (0 => int i; i < scaleNames.size(); i++){
            scaleNames[i] => string name;
            utils.scaleMap[name] @=> int scale[];
            if (size != scale.size()) continue;
            chord[0] - scale[0] => int offset;
            0 => int broken;
            for (0 => int j; j < size; j++){
               if (chord[j] - scale[j] != offset) {
                    1 => broken;
                    break;
               }
            }
            if (broken) continue;
            utils.getPitchClass(offset) => string tonic;
            return tonic + " " + name;
        }

        // Check for an inversion
        for (0 => int j; j < size; j++){
            chord[j] => int root;
            int invertedChord[0];
            for (0 => int k; k < size; k++){
                utils.mod(chord[(j + k) % size] - root, 12) => int interval;
                invertedChord << interval;
            }
            for (0 => int i; i < scaleNames.size(); i++){
                scaleNames[i] => string name;
                utils.scaleMap[name] @=> int scale[];
                if (size != scale.size()) continue;
                0 => int broken;
                for (0 => int k; k < size; k++){
                   if (invertedChord[k] != scale[k]) {
                        1 => broken;
                        break;
                   }
                }
                if (broken) continue;
                utils.getPitchClass(root) => string tonic;
                return tonic + " " + name + " (r" + (size-j) + ")";
            }
        }

        return utils.list(chord);
    }
    fun string detect(){ return detect(this.chord()); }

    fun Query query(){ return this._query; }
    fun Query query(Query query){ query @=> this._query; return _query; }
    fun string[] queryKeys(string keys[]){ _query.setKeys(keys); return keys; }
    fun string queryDirection(string direction){ _query.setDirection(direction); return direction; }
    fun int querySpread(int spread){ _query.setSpread(spread); return spread; }
    fun int queryIndex(int index){ _query.setIndex(index); return index; }
    fun int queryDegree(int degree){ _query.setDegree(degree); return degree; }

    fun int[] getClosestChord(int returnVector){
        int chord[0];
        _pose.offset @=> int offset[];
        this.chord() @=> chord;
        int vectors[0][0];
        _query.getSearchVectors() @=> vectors;

        int champChords[0][0];
        int champVectors[0][0];
        0 => int index;
        int champIndices[0];
        int champScores[0];

        // Search across every vector
        for (int vector[] : vectors){
            pose(vector);
            transform(0) @=> int newChord[];
            utils.getChordDistance(chord, newChord) => int score;
            utils.getChordError(chord, newChord) => int error;
            if (error == 0) continue;
            if (_query.direction == "up" && error < 0) continue;
            if (_query.direction == "down" && error > 0) continue;
            if (_query.degree != 0 && vector[_query.keys[0]] != _query.degree-1) continue;
            champScores << score;
            champChords << newChord;
            champVectors << vector;
            champIndices << index++;
        }

        // Reset the pose
        pose(offset);

        // Return an empty chord if no matches were found
        if (!champIndices.size()) {
            int empty[0];
            return empty;
        }

        // Sort by score and return the chosen index
        utils.mergeSort(champIndices, champScores) @=> champIndices;
        if (_query.index > index) {
            if (returnVector) return champVectors[0];
            return champChords[0];
        }
        champIndices[Math.min(_query.index, champIndices.size() - 1)] => int chosenIndex;
        if (returnVector) return champVectors[chosenIndex];
        return champChords[chosenIndex];
    }
    fun int[] getClosestChord(int returnVector, Query query){
        query @=> this._query;
        return getClosestChord(returnVector);
    }
    fun int[] getClosestChord(){ return getClosestChord(0); }
    fun int[] getClosestPose(){ return getClosestChord(1); }
    fun void printClosestChord(){ utils.print(getClosestChord()); }

}