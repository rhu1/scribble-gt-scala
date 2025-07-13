package com.github.rhu1.gt.util


object Util {

}


/* ... */

implicit class PipeForwards[A](a: A) extends AnyVal {
    def |>[B](f: A => B): B = f(a)
}

implicit class PipeBackwards[A, B](val f: A => B) {
    def <| (a: A): B = f(a)
}
