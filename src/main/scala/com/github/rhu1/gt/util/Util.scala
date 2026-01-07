package com.github.rhu1.gt.util

import scala.annotation.targetName


object Util {

}


/* ... */

implicit class PipeForwards[A](val a: A) extends AnyVal {
    @targetName("pipe forwards")
    def |>[B](f: A => B): B = f(a)
}

implicit class PipeBackwards[A, B](val f: A => B) extends AnyVal {
    @targetName("pipe backwards")
    def <| (a: A): B = f(a)
}
