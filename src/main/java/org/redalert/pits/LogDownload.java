package org.redalert.pits;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class LogDownload {
    public int download(String ip, String path) {
        FTPClient ftp = new FTPClient();
        System.out.println("Connecting to robot");
        try {
            ftp.connect(ip);
            ftp.login("anonymous", "");
            ftp.changeWorkingDirectory(path);
            System.out.println("Connected to robot");
            if (!FTPReply.isPositiveCompletion(ftp.getReplyCode())) {
                ftp.disconnect();
                System.err.println("FTP server dropped the connection: Error " + ftp.getReplyCode());
                return 2;
            }
            try {
                String[] files = ftp.listNames();
                if (files != null) {
                    for (int x = 0; x < files.length; x++) {
                        String remoteFilePath = path + "/" + files[x];
                        String localFilePath =  "./logs/" + files[x];
                        PITSUtility.setStatus((x + 1) + "/" + files.length + ": " + files[x]);
                        OutputStream outputStream = new FileOutputStream(localFilePath);
                        if (ftp.retrieveFile(remoteFilePath, outputStream)) {
                            System.out.println("Downloaded file " + remoteFilePath);
                        }
                    }
                }
                ftp.disconnect();
                return 0;
            } catch (IOException ioe) {
                System.out.println("IO exception");
            }

        } catch (IOException e) {
            System.out.println("Connection failed");
            return 1;
        }
        return 0;
    }
}
