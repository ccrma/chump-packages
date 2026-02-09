@import "utils.ck"
@import "scale.ck"
@import "note.ck"

public class Regex {
    Utils utils;

    // Convert a string to a midi scale
    fun int[] inputScale(string input){

        // Try to find an exact name for the scale
        if (utils.scaleMap.isInMap(input)){
            utils.scaleMap[input] @=> int match[];
            return utils.sumScale(match, 60);
        }

        input.length() => int length;

        // Try to find an exact name with a prefixed pitch class
        for (string name : utils.scaleNames){
            name.length() => int nameLength;
            if (length < nameLength) continue;

            // Check if scale ends with the name
            if (input.substring(length - nameLength, nameLength) == name){
                input.substring(0, length - nameLength).trim() => string substring;
                utils.pitchClassToNumber(substring) => int number;
                if (number < 0) continue;
                return utils.sumScale(utils.scaleMap[name], number + 60);
            }
        }

        // Try to split the scale by comma
        int notes[0];
        1 => int onTonic;
        utils.split(input, ",") @=> string parts[];
        for (string part : parts){
            part.trim() => string note;
            utils.pitchClassToNumber(note) => int number;
            if (number < 0) continue;
            if (onTonic){
                notes << number + 60;
                0 => onTonic;
            } else {
                notes[notes.size() - 1] => int last;
                utils.mod(number - (last % 12), 12) => int dist;
                notes << last + dist;
            }
        }
        return notes;
    }

    // Convert a string to an array of MIDI scales
    // Ex: "C major > major chord" -> [[60, 62, 64, 65, 67, 69, 71], [60, 64, 67]]
    fun int[][] inputScales(string input){
        int scales[0][0];
        if (input == "") return scales;
        utils.split(input, ">") @=> string parts[];
        for (string part : parts){
            part.trim() => string p;
            if (p.length() == 0) continue;
            inputScale(p) @=> int scale[];
            if (scale.size() == 0) continue;
            utils.sortScale(scale) @=> int sorted[];
            scales << sorted;
        }
        return scales;
    }

    // Convert a string to a pose vector
    // Ex. "A5 + B-2 + B1" -> {"A": 5, "B": -1}
    fun int[] inputVector(string input){
        int result[0];
        input.trim() => string trimmed;
        utils.split(trimmed, "+") @=> string parts[];
        for (string part : parts){
            part.trim() => string p;
            if (p.length() == 0) continue;

            // Get the letter
            "" => string s;
            s.appendChar(p.charAt(0)) => string letter;
            if (letter < "a" || letter > "z") continue;

            // Get the number
            if (p.length() == 1){
                1 => result[letter];
            } else {
                p.substring(1).trim().toInt() => int value;
                if (!result.isInMap(letter)) 0 => result[letter];
                value +=> result[letter];
            }
        }
        return result;
    }
}