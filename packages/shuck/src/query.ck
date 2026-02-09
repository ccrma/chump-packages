public class Query {
    string keys[];
    string direction;
    int spread;
    int index;
    int degree;

    fun @construct(string keys[], string direction, int spread, int index, int degree){
        keys @=> this.keys;
        direction => this.direction;
        spread => this.spread;
        index => this.index;
        degree => this.degree;
    }
    fun @construct(string keys[], string direction, int spread, int index){
        this(keys, direction, spread, index, 0);
    }
    fun @construct(string keys[], string direction, int spread){
        this(keys, direction, spread, 0, 0);
    }
    fun @construct(string keys[], string direction){
        this(keys, direction, 5, 0, 0);
    }
    fun @construct(string keys[]){
        this(keys, "any", 5, 0, 0);
    }
    fun @construct(){
        this(["a"], "any", 5, 0, 0);
    }

    fun void setKeys(string keys[]){ keys @=> this.keys; }
    fun void setDirection(string direction){ direction @=> this.direction; }
    fun void setSpread(int spread){ spread @=> this.spread; }
    fun void setIndex(int index){ index @=> this.index; }
    fun void setDegree(int degree){ degree @=> this.degree; }

    fun int[][] getSearchVectors(){
        spread * 2 + 1 => int range;
        Math.pow(range, keys.size()) $ int => int searchSize;
        int searchVectors[searchSize][0];
        for (0 => int i; i < searchSize; i++){
            int offset[0];
            i => int index;
            for (string key : keys){
                (index % range) - spread => int value;
                if (value) value => offset[key];
                Math.floor(index / range) $ int => index;
            }
            offset @=> searchVectors[i];
        }
        return searchVectors;
    }
}
