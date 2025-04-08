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

        PITSUtility.setStatus("Connecting to robot...");

        try {
            ftpClient.connect(ip);
            ftpClient.enterLocalPassiveMode();
            ftpClient.login("anonymous", "");
            ftpClient.changeWorkingDirectory(path);

            PITSUtility.setStatus("Connected to robot");

            if (!FTPReply.isPositiveCompletion(ftpClient.getReplyCode())) {
                ftpClient.disconnect();

                PITSUtility.setStatus("Error: FTP server dropped the connection (code " + ftpClient.getReplyCode() + ")");

                return PITSError.REFUSED_CONNECTION;
            }

            try {
                String[] files = ftpClient.listNames();

                if (files != null) {
                    File folderCheck = new File("./logs");

                    if (!folderCheck.exists()) {
                        try {
                            if (folderCheck.mkdir()) {
                                PITSUtility.setStatus("Created log folder");
                            } else {
                                return PITSError.FAILED_DOWNLOAD_DIRECTORY_CREATION;
                            }
                        } catch (SecurityException securityException) {
                            PITSUtility.setStatus("SecurityException when creating log folder");
                        }
                    }

                    for (int i = 0; i < files.length; i++) {
                        String remoteFilePath = path + "/" + files[i];
                        String localFilePath =  "./logs/" + files[i];

                        PITSUtility.setStatus((i + 1) + "/" + files.length + ": " + files[i]);

                        OutputStream outputStream = new FileOutputStream(localFilePath);
                        if (ftpClient.retrieveFile(remoteFilePath, outputStream)) {
                            PITSUtility.setStatus("Downloaded file " + remoteFilePath);

                            if (delete) {
                                ftpClient.deleteFile(remoteFilePath);

                                PITSUtility.setStatus("Deleted file " + remoteFilePath);
                            }
                        }
                    }

                    PITSUtility.setStatus("**************DONE**************");
                }

                ftpClient.disconnect();

                return PITSError.SUCCESS;
            } catch (IOException ioException) {
                PITSUtility.setStatus("IOException occured while reading log file list");
            }

        } catch (IOException ioException) {
            PITSUtility.setStatus("Connection failed");

            return PITSError.FAILED_CONNECTION;
        }

        return PITSError.SUCCESS;
    }
}
