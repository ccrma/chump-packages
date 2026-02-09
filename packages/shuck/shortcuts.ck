@import "src/tree.ck"
@import "src/utils.ck"

public class Listener {
    Utils utils;
    Hid hi;
    HidMsg msg;
    0 => int device;
    int activeKeys[26];
    0 => int isNegative;
    0 => int isFindingClosest;
    0 => int isFindingDegree;
    0 => int isListening;
    1::minute => dur timeout;
    Tree tree;
    Shred timeoutShred;
    int baseChord[];

    fun @construct(Tree tree) {
        if (me.args()) me.arg(0) => Std.atoi => device;
        if (!hi.openKeyboard(device)) me.exit();
        tree.chord() @=> baseChord;
        tree @=> this.tree;
    }

    fun void setTree(Tree tree){ tree @=> this.tree; tree.chord() @=> baseChord; }
    fun void setTimeout(dur timeout){ timeout => this.timeout; }

    fun void startTimeout(){
        timeout => now;
        stop();
    }

    fun void listen(){
        1 => isListening;
        spork ~ startTimeout() @=> timeoutShred;
        hi => now;
        <<< "Listening for shortcuts..." >>>;
        while(isListening){
            if (timeoutShred.done()) {
                0 => isListening;
                break;
            }
            while (hi.recv(msg)){
                msg.ascii => int key;

                // Toggle negative hold
                if (key == 45 || key == 96){
                    msg.isButtonDown() ? 1 : 0 => isNegative;
                }

                // Toggle keyboard hoard
                if (key > 64 && key < 91){
                    if (msg.isButtonDown()){
                        1 => activeKeys[key - 65];
                    } else {
                        0 => activeKeys[key - 65];
                    }
                }

                // Toggle voice leading with comma
                if (key == 44){
                    msg.isButtonDown() ? 1 : 0 => isFindingClosest;
                }
                // Toggle degree finding with period
                if (key == 46){
                    msg.isButtonDown() ? 1 : 0 => isFindingDegree;
                }

                // Handle keypresses
                if (!msg.isButtonDown()) continue;

                // Clear pose on 0
                if (key == 48){ 
                    tree.clear(); 
                }

                // Add or voice lead pose on number press
                if (key > 48 && key < 58){

                    if (isFindingClosest){
                        if (isNegative) tree.queryDirection("down");
                        else tree.queryDirection("any");
                        tree.queryIndex(key - 49);
                        tree.queryDegree(0);
                        tree.getClosestPose() @=> int closestVector[];
                        if (!closestVector.size()) continue;
                        tree.add(closestVector);
                        continue;
                    }

                    if (isFindingDegree){
                        if (isNegative) tree.queryDirection("down");
                        else tree.queryDirection("any");
                        tree.queryIndex(0);
                        tree.queryDegree(key - 48);
                        tree.getClosestPose() @=> int closestVector[];
                        <<<closestVector.size()>>>;
                        if (!closestVector.size()) continue;
                        utils.print(closestVector);
                        tree.add(closestVector);
                        continue;
                    }

                    int offset[0];
                    for (0 => int i; i < 26; i++){
                        if (activeKeys[i]){
                            (key - 48) => int value;
                            isNegative ? -value : value => offset[utils.numToLetter(i,1)];
                        }
                    }
                    tree.add(offset);
                }
            }
            10::ms => now;
        }
    }

    fun void stop(){ 0 => isListening; }
}