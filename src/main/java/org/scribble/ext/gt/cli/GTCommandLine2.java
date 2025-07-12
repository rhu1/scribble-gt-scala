package org.scribble.ext.gt.cli;

import org.scribble.ast.Module;
import org.scribble.ast.global.GProtoDecl;
import org.scribble.cli.CLFlags;
import org.scribble.cli.CommandLine;
import org.scribble.cli.CommandLineException;
import org.scribble.core.job.Core;
import org.scribble.core.job.CoreArgs;
import org.scribble.core.type.name.ModuleName;
import org.scribble.ext.gt.main.GTMain;
import org.scribble.job.Job;
import org.scribble.main.resource.locator.DirectoryResourceLocator;
import org.scribble.main.resource.locator.ResourceLocator;
import org.scribble.util.*;

import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class GTCommandLine2 extends CommandLine {

    // Used in GTJob
    public static List<Pair<String, String[]>> ARGS;


    // i.e., check Correspondence (modulo GTCLFlags.NO_CORRESPONDENCE flag)
    public Map<ModuleName, Module> gtMain() {
        return getTranslated(this);
    }
























    /* Parent Scribble stuff */

    protected GTMain main;  // Hack for parsed modules, should use Job instead

    public GTCommandLine2(String... args) {
        super(args);

        GTCommandLine2.ARGS = this.args;
        try {
            run();
        } catch (CommandLineException | AntlrSourceException x) {
            throw new RuntimeScribException(x);
        }
    }

    public static void main(String[] args) {
        GTCommandLine2 cl = new GTCommandLine2(args);
        //Optional<Exception> run =
        cl.gtMain();
        //run.forEach(_x -> throw new RuntimeException(run.get()));
    }

    /*public static Optional<Exception> mainTest(String[] args) {
        GTCommandLine2 cl = init(args);
        return cl.gtMain();
    }*/

    //static Map<GProtoName, GTGType> getTranslated(GTCommandLine2 cl) {
    static Map<ModuleName, Module> getTranslated(GTCommandLine2 cl) {
        //Map<GProtoName, GTGType> res = new HashMap<>();

        Job job = cl.getJob();
        Core core = job.getCore();
        boolean debug = core.config.hasFlag(CoreArgs.VERBOSE);

        //Map<ModuleName, Module> parsed = cl.main.getParsedModules();  // XXX original source, no disamb
        Map<ModuleName, Module> parsed = job.getContext().getParsed();// !!! post disamb
        if (debug) {
            System.out.println("\n----- GT -----\n");
            System.out.println("[GTCommandLine2] Parsed modules: " + parsed.keySet());
        }

        for (ModuleName n : parsed.keySet()) {
            Module m = parsed.get(n);
            for (GProtoDecl g : m.getGProtoDeclChildren()) {
                //GTGType translate = new GTGTypeTranslator3().translate(g.getDefChild().getBlockChild().getInteractSeqChild());
                /*if (debug) {
                    System.out.println("\n[GTCommandLine2] Translated "
                            + g.getHeaderChild().getDeclName() + ": " + translate);
                }
                res.put(g.getFullMemberName(parsed.get(n)), translate);*/
                System.out.println("\n" + g);
            }
        }
        //return res;

        return parsed;
    }

    @Override
    protected CLFlags newCLFlags() {
        return new GTCLFlags();
    }

    @Override
    protected void doValidationTasks(Job job) throws
            AntlrSourceException, ScribParserException,  // Latter in case needed by subclasses
            CommandLineException {
        job.runPasses();

        //job.getCore().runPasses();  // ...base imed GTGMixedChoice visit/agg/gather overrides
    }

    @Override
    protected void tryBarrierTask(Job job, Pair<String, String[]> task) throws ScribException, CommandLineException {
        // `run` happens before `gtRun` -- skip GT flags in `run`
        switch (task.left) {
            case GTCLFlags.GT_ED_FSM_GEN_FLAG:
                break;
            case GTCLFlags.GT_ERLANG_API_GEN_FLAG:
                break;
            default:
                super.tryBarrierTask(job, task);
        }
    }


    // Duplicated from AssrtCommandLine
    // Based on CommandLine.newMainContext
    @Override
    protected GTMain newMain() throws ScribParserException, ScribException {
        Map<CoreArgs, Boolean> args = Collections.unmodifiableMap(parseCoreArgs());
        if (hasFlag(CLFlags.INLINE_MAIN_MOD_FLAG)) {
            String inline = getUniqueFlagArgs(CLFlags.INLINE_MAIN_MOD_FLAG)[0];
            this.main = new GTMain(inline, args);
        } else {
            List<Path> impaths =
                    hasFlag(CLFlags.IMPORT_PATH_FLAG)
                    ? CommandLine.parseImportPaths(getUniqueFlagArgs(CLFlags.IMPORT_PATH_FLAG)[0])
                    : Collections.emptyList();
            ResourceLocator locator = new DirectoryResourceLocator(impaths);
            Path mainpath = CommandLine
                    .parseMainPath(getUniqueFlagArgs(CLFlags.MAIN_MOD_FLAG)[0]);
            this.main = new GTMain(locator, mainpath, args);
        }
        return this.main;
    }


    /* Aux for parent Scribble stuff */

    private boolean hasFlag(String flag) {
        return this.args.stream().anyMatch(x -> x.left.equals(flag));
    }

    private String[] getUniqueFlagArgs(String flag) {
        return this.args.stream()
                        .filter(x -> x.left.equals(flag)).findAny().get().right;
    }
}
