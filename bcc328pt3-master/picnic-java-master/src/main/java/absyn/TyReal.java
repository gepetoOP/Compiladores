package absyn;

import env.Env;
import io.vavr.collection.Tree;
import types.Type;
import types.REAL;

public class TyReal extends Ty{
    public TyReal(Loc loc) {
        super(loc);
    }

    @java.lang.Override
    public Tree.Node<String> toTree() {
        return Tree.of("real");
    }

    @Override
    public Type semantic(Env env) {
        return REAL.T;
    }
}
