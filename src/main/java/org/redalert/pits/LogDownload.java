package org.redalert.pits;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;

import java.io.IOException;

public class LogDownload {
    public int download(String ip, String path) {
        FTPClient ftp = new FTPClient();
        System.out.println("IP input: " + ip + "\nPath \"input\": " + path + "\n");
        System.out.println("Connecting to robot");
        try {
            ftp.connect(ip);
            System.out.println("Connected to robot");
            if (!FTPReply.isPositiveCompletion(ftp.getReplyCode())) {
                ftp.disconnect();
                System.err.println("FTP server rejected the connection");
                System.exit(2);
            }
            try {
                ftp.disconnect();
                return 0;
            } catch (IOException ioe) {
                // do nothing
            }

        } catch (IOException e) {
            System.out.println("Connection failed");
            return 1;
        }
        return 0;
    }
}
