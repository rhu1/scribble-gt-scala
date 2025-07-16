package com.github.rhu1.gt.util


object Util {

}


/* ... */

implicit class PipeForwards[A](val a: A) extends AnyVal {
    def |>[B](f: A => B): B = f(a)
}

implicit class PipeBackwards[A, B](val f: A => B) extends AnyVal {
    def <| (a: A): B = f(a)
}
