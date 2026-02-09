@import "utils.ck"
@import "note.ck"

public class Scale {
    string id;
    Note notes[0];
    Utils utils;

    fun @construct(string id, Note notes[]){
        id => this.id;
        notes @=> this.notes;
    }

    // Resolve to MIDI using the chromatic scale
    fun int[] unpack(){
        int notes[0];
        for (Note note : this.notes){
            notes << note.unpack();
        }
        return notes;
    }

    // Transpose a note along the scale by appling offsets and adjusting octave
    fun Note transposeNote(Note note){
        notes.size() => int modulus;
        if (modulus == 0) return note;

        // Find the new degree and octave
        0 => int degreeOffset;
        if (note.offset.isInMap(id)){ note.offset[id] => degreeOffset;}
        (degreeOffset != 0) => int shouldOffset;
        note.degree + degreeOffset => int newDegree;
        utils.bottomFloor(newDegree, modulus) => int newOctave;

        // Get the new note from the parent scale
        notes[utils.mod(newDegree, modulus)] @=> Note parentNote;

        // Create new offsets for the note
        note.offset @=> int newOffset[];
        if (shouldOffset) newOffset.erase(id);

        // Inherit the parent's offsets
        parentNote.offset @=> int parentOffset[];
        utils.sumVectors(newOffset, parentOffset) @=> newOffset;

        // Apply the octave to the note
        int octaveOffset[0];
        if (newOctave != 0) newOctave => octaveOffset["y"];
        utils.sumVectors(newOffset, octaveOffset) @=> newOffset;

        // Return the new note
        Note newNote(parentNote.id, parentNote.degree, newOffset);
        return newNote;
    }

    // Transpose a scale through a parent scale
    fun Scale transposeScale(Scale child){
        Note notes[0];
        child.notes.size() => int size;
        for (0 => int i; i < size; i++){
            notes << transposeNote(child.notes[i]);
        }
        return new Scale(this.id, notes);
    }

    // Convert a scale to a string
    fun string toString(){
        "" => string result;
        notes.size() => int size;
        for (0 => int i; i < size; i++){
            notes[i].toString(1) +=> result;
            if (i < size - 1) {
                "," +=> result;
            }
        }
        return result;
    }
}
