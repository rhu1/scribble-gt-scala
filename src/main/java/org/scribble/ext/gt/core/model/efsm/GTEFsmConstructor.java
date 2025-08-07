package org.scribble.ext.gt.core.model.efsm;

import org.scribble.core.type.name.Op;
import org.scribble.core.type.name.RecVar;
import org.scribble.core.type.name.Role;
import org.scribble.core.type.session.Payload;

import org.scribble.ext.gt.core.model.efsm.GTEFSM;
import org.scribble.ext.gt.core.model.efsm.GTVState;
import org.scribble.ext.gt.core.model.efsm.event.GTVAction;
import org.scribble.ext.gt.core.model.efsm.event.GTVEpsilon;
import org.scribble.ext.gt.core.model.efsm.event.GTVEvent;
import org.scribble.ext.gt.core.model.efsm.event.GTVRecv;
import org.scribble.util.Pair;

import java.util.*;

@Deprecated
public class GTEFsmConstructor {

    //public static GTEFSM construct(Role r, Map<Integer, Set<Op>> com, Map<Integer, Pair<GTVRecv, GTVState>> recvStars, int c, GTVState s, GTVState end) {}  // c == s.c on call


    /*// ...from GTLBranch
    public static GTEFSM construct(Role src, Map<Op, Payload> pays, Map<Op, GTLType> cases,
            Role r, Map<Integer, Set<Op>> com, Map<Integer, Pair<GTVRecv, GTVState>> recvStars,
                                   int c, GTVState s, GTVState end) {  // c == s.c on call
        Set<GTVState> S = new LinkedHashSet<>();
        S.add(s);
        Set<GTVEvent> E = new LinkedHashSet<>();
        Set<GTVAction> A = new LinkedHashSet<>();
        Map<Pair<GTVState, GTVEvent>, Set<Pair<GTVAction, GTVState>>> delta = new LinkedHashMap<>();
        for (Map.Entry<Op, GTLType> x : this.cases.entrySet()) {
            Op op_i = x.getKey();
            GTLType succ_i = x.getValue();
            //Map<Integer, Pair<GTVRecv, GTVState>> stars = com.contains(op_i) ? Map.of() : recvStars;
            Map<Integer, Pair<GTVRecv, GTVState>> stars = new HashMap<>(recvStars);
            for (Map.Entry<Integer, Set<Op>> y : com.entrySet()) {
                if (y.getValue().contains(op_i)) {
                    stars.remove(y.getKey());
                }
            }
            GTVState s_i = new GTVState(c);
            GTEFSM m_i = succ_i.construct(r, com, stars, c, s_i, end);
            S.addAll(m_i.S);
            E.addAll(m_i.E);
            A.addAll(m_i.A);
            GTVRecv e = new GTVRecv(this.src, op_i, this.pays.get(op_i));

            Set<Pair<GTVAction, GTVState>> tmp = delta.computeIfAbsent(new Pair<>(s, e), y -> new LinkedHashSet<>());
            tmp.add(new Pair<>(GTVEpsilon.EPSILON, m_i.init));
            for (Map.Entry<Pair<GTVState, GTVEvent>, Set<Pair<GTVAction, GTVState>>> y : m_i.delta.entrySet()) {
                Pair<GTVState, GTVEvent> k = y.getKey();
                Set<Pair<GTVAction, GTVState>> tmp2 = delta.computeIfAbsent(k, z -> new LinkedHashSet<>());
                tmp2.addAll(y.getValue());
            }
        }

        GTLMixedChoice.drawExternals(recvStars, s, delta);
        return new GTEFSM(S, s, E, A, delta);
    }*/
}
