@import "utils.ck"

public class Pose {
    Utils utils;
    int offset[0];

    // Initialize an empty array
    fun @construct(){
        int array[0];
        array @=> offset;
    }

    // Construct the offset
    fun @construct(int offset[]){
        string keys[0];
        offset.getKeys(keys);
        for (0 => int i; i < keys.size(); i++){
            keys[i] => string key;
            offset[key] => int value;
            value => this.offset[key];
        }
    }

    // Set a value by key
     fun void set(string key, int value){
        value => offset[key];
     }

    // Add a value by key
    fun void add(string key, int value){
        value +=> offset[key];
    }

    // Sum with another pose
    fun void sum(Pose other){
        return this(utils.sumVectors(this.offset, other.offset));
    }

    // Reset the values of a pose
    fun void clear(){ 
        this();
     }

    // Convert a pose to a string
    fun string toString(){
        "" => string result;
        for (0 => int i; i < 26; i++){
            utils.numToLetter(i, 1) => string letter;
            if (offset[letter]){
                letter + offset[letter] + "+" +=> result;
            }
        }
        result.length() => int length;
        if (length){ return result.substring(0, length - 1); }
        return result;
    }
}