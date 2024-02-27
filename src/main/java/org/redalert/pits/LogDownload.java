package org.redalert.pits;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;

import org.apache.commons.io.FileUtils;

import javax.swing.JOptionPane;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.File;

public class LogDownload extends Thread {
    String ip;
    String path;

    @Override
    public void run() {
        PITSUtility.displayStatus(download(ip, path));
    }
    public LogDownload(String ip, String path) {
        this.ip = ip;
        this.path = path;
    }

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
                    File folderCheck = new File("./logs");
                    if (!folderCheck.exists()) {
                        try {
                            if (folderCheck.mkdir()) {
                                System.out.println("Created log folder");
                            } else {
                                return 3;
                            }
                        } catch (SecurityException e) {
                            System.out.println("Security exception when creating log folder");
                        }
                    } else {
                        int reply = JOptionPane.showConfirmDialog(null, "Log folder already exists. Overwrite it?", "Overwrite folder", JOptionPane.YES_NO_OPTION);
                        if (reply == JOptionPane.YES_OPTION) {
                            try {
                                FileUtils.deleteDirectory(new File("./logs"));
                                if (folderCheck.mkdir()) {
                                    System.out.println("Overwrote log folder");
                                } else {
                                    return 3;
                                }
                            } catch (SecurityException e) {
                                System.out.println("Security exception when overwriting log folder");
                            }
                        } else {
                            return 3;
                        }
                    }
                    for (int x = 0; x < files.length; x++) {
                        String remoteFilePath = path + "/" + files[x];
                        String localFilePath =  "./logs/" + files[x];
                        PITSUtility.setStatus((x + 1) + "/" + files.length + ": " + files[x]);
                        OutputStream outputStream = new FileOutputStream(localFilePath);
                        if (ftp.retrieveFile(remoteFilePath, outputStream)) {
                            System.out.println("Downloaded file " + remoteFilePath);
                        }
                    }
                    PITSUtility.setStatus("**************READY**************");
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
