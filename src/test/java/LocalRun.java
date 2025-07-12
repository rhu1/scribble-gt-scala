import org.scribble.ext.gt.cli.GTCommandLine2;

public class LocalRun {

    public static void main(String[] args) {
        //String path = TestUtil.BASE_PATH + "\\s5\\good\\table1\\SMTP.scr";  // XXX paths from JUnit @test seem different?
        String path = "C:\\Users\\Raymond\\winroot\\home\\eey335\\code\\java\\intellij\\git\\github.com\\rhu1-scribble-core-gt\\scribble-java\\scribble-gt\\src\\test\\java\\oopsla25\\s5\\good\\table1\\SMTP.scr";
        GTCommandLine2.main(new String[]{path, "-fair", "-v"});
    }
}
