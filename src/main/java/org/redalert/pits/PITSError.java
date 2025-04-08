package org.redalert.pits;

public interface PITSError {
    int SUCCESS = 0;
    int FAILED_CONNECTION = -1;
    int REFUSED_CONNECTION = -2;
    int FAILED_DOWNLOAD_DIRECTORY_CREATION = -3;
}
