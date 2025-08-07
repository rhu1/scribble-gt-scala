package org.scribble.ext.gt.core.model.efsm.event;


public class GTVEpsilonStar implements GTVAction {

    public static final GTVEpsilonStar EPSILON_STAR = new GTVEpsilonStar();

    protected GTVEpsilonStar() {
    }

    @Override
    public String toString() {
        return GTVEpsilon.CONSOLE_EPSILON + "*";
    }

    @Override
    public int hashCode() {
        int hash = 15497;
        return hash;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof GTVEpsilonStar cast)) {
            return false;
        }
        return true;
    }
}
