package com.varentech.deploya.form;

import com.google.common.hash.HashCode;
import com.google.common.hash.Hashing;
import com.google.common.io.Files;
import com.varentech.deploya.daoimpl.EntriesDetailsDaoImpl;
import com.varentech.deploya.entities.EntriesDetail;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ResourceBundle;
import java.util.concurrent.*;


/**
 * This class manages the given Linux shell commands and prints the stdOutput and stdErr of both.
 * Contains methods to executes, unpack, and find the md5 hash of all files.
 */

public class ProcessFile {

    private Logger logg = LoggerFactory.getLogger(ProcessFile.class);

  /**
     * Executes a file in the terminal using the execute command given by the user.
     * Prints the standard output and standard error and adds them to the database.
     * Time outs after time given by user in config.properties file.
     */
    public void executeArguments() {

        ResourceBundle resource = ResourceBundle.getBundle("config");
        int timeout = Integer.parseInt(resource.getString("execute_timeout"));

        ExecutorService service = Executors.newSingleThreadExecutor();

        try {
            Runnable r = new Runnable() {
                public void run() {

                    try {

                        Resource res = new Resource();
                        String output = "";

                        Process p = Runtime.getRuntime().exec(res.entry.getExecuteArguments());
                        BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
                        String line = null;

                        while ((line = in.readLine()) != null) {
                            output = output + line;
                        }

                        String stdErr = "";
                        BufferedReader stdErrReader = new BufferedReader(
                                new InputStreamReader(p.getErrorStream()));

                        while ((line = stdErrReader.readLine()) != null) {
                            stdErr = stdErr + line;
                        }

                        //save output and error
                        res.entriesDetail.setOutput(output);
                        res.entriesDetail.setError(stdErr);
                    } catch (IOException e) {
                       logg.error("Exception while executing the file: ", e);
                    }
                }
            };

            Future<?> f = service.submit(r);

            if(timeout!=-1) {
                f.get(timeout, TimeUnit.MINUTES);     // attempt the task for one minute
            }
        } catch (final InterruptedException e) {
            logg.error("Thread interrupted during sleep: ", e);
        } catch (final TimeoutException e) {
           logg.error("Execution timed out: ", e);
            Resource res = new Resource();
            res.entriesDetail.setError("Execute command timed out after" + timeout + " minute(s)." + res.entriesDetail.getError());
        } catch (final ExecutionException e) {
            logg.error("Exception from within Runnable task: ", e);
            // TODO: Tav: Do we not care about this exception? Its ok if we
            // don't, but its a good idea to say why we don't. Otherwise it
            // looks like we are ignoring a potentially important exception.
        }
    }

    /**
     * Unpacks all files into a temporary directory.
     * Prints the standard output and standard error and adds them to the database.
     */
    public File unpack(File current) {

        Resource res = new Resource();
        String file_name = current.getName();
        int dot = file_name.lastIndexOf('.');
        String fileExtension = file_name.substring(dot);
        Process p = null;

        try {
            logger.debug("Unpack to the temporary directory");

            if (fileExtension.equals(".tar")) {
                p = Runtime.getRuntime().exec("tar -xf " + current + " -C " + current.getParent());

            } else if (fileExtension.equals(".gz") || fileExtension.equals(".tgz")) {
                p = Runtime.getRuntime().exec("tar -xzf " + current + " -C " + current.getParent());

            } else if (fileExtension.equals(".zip") || fileExtension.equals(".jar")) {
                p = Runtime.getRuntime().exec("unzip " + current + " -d " + current.getParent());

            } else {
                logg.error("Incorrect file extension: ", fileExtension);
            }

            String stdErr = "";
            String line;
            BufferedReader stdErrReader = new BufferedReader(
                    new InputStreamReader(p.getErrorStream()));

            while ((line = stdErrReader.readLine()) != null) {
                stdErr = stdErr + line;
            }

            res.entriesDetail.setError(stdErr);

        } catch (IOException e) {
            logg.error("Exception while unpacking to temporary directory: ", e);
        }

        return current.getParentFile();
    }

  /**
     * This method finds the hash value of each individual file in an array, and it is then inserted into our database.
     */
    public void hashFiles(File[] fileList, File current) {
        Resource res = new Resource();
        FormServlet form = new FormServlet();

        for (int i = 0; i < fileList.length; i++) {

            File file = fileList[i];
            try {
                String fileName = file.getName();
                HashCode hashCode = null;

                if (!file.isDirectory()) {
                    hashCode = Files.hash(file, Hashing.md5());
                }

                if (file.equals(current)) {
                    res.entriesDetail.setHashValue(hashCode.toString());
                    logger.debug("Hash code was found for {}.", fileName);
                } else {

                    EntriesDetail subentry = new EntriesDetail();
                    EntriesDetailsDaoImpl imp = new EntriesDetailsDaoImpl();

                    subentry.setFileName(form.renaming(fileName));
                    subentry.setOutput(res.entriesDetail.getOutput());
                    subentry.setError(res.entriesDetail.getError());
                    if (!file.isDirectory()) {
                        subentry.setHashValue(hashCode.toString());
                    }

                    imp.insertIntoEntriesDetail(subentry);
                    logger.debug("{} was added to the database.", fileName);

                }

            } catch (IOException e) {
             logg.error("Exception while finding the hash of file {} : ", file.getName(), e);
                continue;
            }
        }
    }
}
