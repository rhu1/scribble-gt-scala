import scala.sys.process.Process

ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "3.3.6"

lazy val root = (project in file("."))
  .settings(
    name := "scribble-gt-scala",
    Compile / mainClass := Some("com.github.rhu1.gt.main.Main")
  )

libraryDependencies += "org.scalatest" %% "scalatest" % "3.2.19" % Test

libraryDependencies += "org.antlr" % "antlr-runtime" % "3.5.2"

Compile / sourceGenerators += Def.task {
  val grammarDir = (Compile / sourceDirectory).value / "antlr3"
  val outDir     = (Compile / sourceManaged).value / "antlr"
  val cp         = (Compile / dependencyClasspath).value.files.mkString(":")

  (grammarDir ** "*.g").get.map { grammarFile =>
    IO.createDirectory(outDir)
    Process(
      Seq(
        "java",
        "-cp", cp,
        "org.antlr.Tool",
        "-o", outDir.getAbsolutePath,
        grammarFile.getAbsolutePath
      ),
      baseDirectory.value
    ).!
    grammarFile
  }
  (outDir ** "*.java").get
}.taskValue

Compile / unmanagedSourceDirectories += baseDirectory.value / "target/generated-sources/antlr3"
