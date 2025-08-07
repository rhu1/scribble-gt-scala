package org.scribble.ext.gt.core.model.efsm.event;


public class GTVEpsilon implements GTVAction {

    public static final String CONSOLE_EPSILON = "\u03B5";

    public static final GTVEpsilon EPSILON = new GTVEpsilon();

    protected GTVEpsilon() {
    }

    @Override
    public String toString() {
        return CONSOLE_EPSILON;
    }

    @Override
    public int hashCode() {
        int hash = 15473;
        return hash;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof GTVEpsilon cast)) {
            return false;
        }
        return true;
    }
}
