package org.redalert.pits;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.File;

public class LogDownload extends Thread {
    private final String ip;
    private final String path;
    private final boolean delete;

    public LogDownload(String ip, String path, boolean delete) {
        this.ip = ip;
        this.path = path;
        this.delete = delete;
    }

    @Override
    public void run() {
        int downloadStatus = download(ip, path, delete);

        PITSUtility.displayStatus(downloadStatus);
    }

    public int download(String ip, String path, boolean delete) {
        FTPClient ftpClient = new FTPClient();

        System.out.println("Connecting to robot");

        try {
            ftpClient.connect(ip);
            ftpClient.enterLocalPassiveMode();
            ftpClient.login("anonymous", "");
            ftpClient.changeWorkingDirectory(path);

            System.out.println("Connected to robot");

            if (!FTPReply.isPositiveCompletion(ftpClient.getReplyCode())) {
                ftpClient.disconnect();

                System.err.println("FTP server dropped the connection: Error " + ftpClient.getReplyCode());

                return PITSError.REFUSED_CONNECTION;
            }

            try {
                String[] files = ftpClient.listNames();

                if (files != null) {
                    File folderCheck = new File("./logs");

                    if (!folderCheck.exists()) {
                        try {
                            if (folderCheck.mkdir()) {
                                System.out.println("Created log folder");
                            } else {
                                return PITSError.FAILED_DOWNLOAD_DIRECTORY_CREATION;
                            }
                        } catch (SecurityException e) {
                            System.out.println("Security exception when creating log folder");
                        }
                    }

                    for (int x = 0; x < files.length; x++) {
                        String remoteFilePath = path + "/" + files[x];
                        String localFilePath =  "./logs/" + files[x];

                        PITSUtility.setStatus((x + 1) + "/" + files.length + ": " + files[x]);

                        OutputStream outputStream = new FileOutputStream(localFilePath);
                        if (ftpClient.retrieveFile(remoteFilePath, outputStream)) {
                            System.out.println("Downloaded file " + remoteFilePath);

                            if (delete) {
                                ftpClient.deleteFile(remoteFilePath);

                                System.out.println("Deleted file " + remoteFilePath);
                            }
                        }
                    }

                    PITSUtility.setStatus("**************DONE**************");
                }
                ftpClient.disconnect();
                return 0;
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }

        } catch (IOException e) {
            System.out.println("Connection failed");

            return PITSError.FAILED_CONNECTION;
        }

        return PITSError.SUCCESS;
    }
}
