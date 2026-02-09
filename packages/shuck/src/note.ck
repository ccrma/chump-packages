@import "utils.ck"

public class Note {
    Utils utils;
    string id;
    int degree;
    int offset[0];

    fun @construct(string id, int degree, int offset[]){
        id => this.id;
        degree => this.degree;
        string keys[0];
        offset.getKeys(keys);
        for (0 => int i; i < keys.size(); i++){
            keys[i] => string key;
            offset[key] => int value;
            value => this.offset[key];
        }
    }

    // Unpack to a chromatic note
    fun int unpack(){
        utils.chromaticNotes[degree % 12] => int base;
        Math.floor(degree / 12) $ int => int wrap;
        if (wrap > 0) wrap * 12 +=> base;
        if (offset.isInMap("t")) offset["t"] +=> base;
        if (offset.isInMap("y")) offset["y"]*12 +=> base;
        return base;
    }
    
    // Convert a scale note into a string
    fun string toString(int asChild){
        "" => string result;
        id => string scaleId;
        if (asChild){
            if (id == "a"){ 
                "t" => scaleId;
            } else {
                utils.letterToNum(id) - 1 => int num;
                utils.numToLetter(num) => scaleId;
            }
        }
        scaleId + ":" + (degree + 1) => result;
        string keys[0];
        offset.getKeys(keys);
        keys.size() => int size;
        for (0 => int i; i < size; i++){
            utils.numToLetter(i, 1) => string letter;
            if (offset[letter]){
                "+" + letter + offset[letter] +=> result;
            }
        }
        if (offset["t"]){
            "+" + "t" + offset["t"] +=> result;
        }
        if (offset["y"]){
            "+" + "y" + offset["y"] +=> result;
        }
        return "(" + result + ")";
    }
    fun string toString(){ 
        return toString(0); 
    }
}